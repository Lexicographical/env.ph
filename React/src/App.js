import React, { useState, useEffect } from 'react';
import { Container, Grid, Form, Message, Radio } from 'semantic-ui-react';
import { Formik } from 'formik';

const TableauEmbed = "<div class='tableauPlaceholder' id='viz1564565260018' style='position: relative'><noscript><a href='#'><img alt=' ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Ai&#47;AirQualityStations&#47;AirQualityStationsLocationDashboard&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='AirQualityStations&#47;AirQualityStationsLocationDashboard' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Ai&#47;AirQualityStations&#47;AirQualityStationsLocationDashboard&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /></object></div>";

function App() {
    let [ deviceList, setDeviceList ] = useState(null);
    useEffect(() => {
        var divElement = document.getElementById('viz1564565260018');                    
        var vizElement = divElement.getElementsByTagName('object')[0];                    
        vizElement.style.width='100%';
        vizElement.style.height=(divElement.offsetWidth*0.50)+'px';                    
        var scriptElement = document.createElement('script');                    
        scriptElement.src = 'https://public.tableau.com/javascripts/api/viz_v1.js';                    
        vizElement.parentNode.insertBefore(scriptElement, vizElement);     
        fetch('https://api.amihan.xyz/list').then(res => res.json()).then(list => {
            setDeviceList(list.sensors.map(x => {
                return {
                    key: x.src_id,
                    text: x.location_name,
                    value: x.src_id
                }
            }));
        }).catch(() => {setDeviceList(false)});    
    }, []);
    return (
        <Container fluid style={{ padding: '4rem' }}>
            <img src="/logo.png" alt="Project Amihan" style={{ maxWidth: '576px', maxHeight: '128px' }} />
            <Grid>
                <Grid.Row>
                    <Grid.Column computer={12} tablet={12} mobile={16}>
                        <span dangerouslySetInnerHTML={{__html: TableauEmbed}} />
                    </Grid.Column>
                    <Grid.Column computer={4} tablet={4} mobile={16}>
                        <h1>Request Dataset:</h1>
                        {deviceList !== null ? (
                            deviceList !== false ? (
                                <Formik
                                    initialValues={{ format: 'json', date_start: '', date_end: '', src_id: '' }}
                                    validate={values => {
                                        console.log(values);
                                        if (values.date_start !== "" && values.date_end !== "" && (new Date(values.date_start)) > (new Date(values.date_end)))  {
                                            return {date_end: "Must be on or after Starting Date"};
                                        } else return {};
                                    }}
                                    onSubmit={(values, {setSubmitting}) => {
                                        window.location.href=`https://api.amihan.xyz/query/data?src_id=${values.src_id}&date_start=${values.date_start}&date_end=${values.date_end}&format=${values.format}`;
                                        setSubmitting(false);
                                    }}
                                >
                                    {({values, errors, handleSubmit, handleChange, isSubmitting, setFieldValue}) => (
                                        <Form onSubmit={handleSubmit}>
                                            <Form.Field>
                                                <label>Source Location (Leaving this field blank will query all sources)</label>
                                                <Form.Dropdown value={values.src_id} name="src_id" id="src_id" selection placeholder="Select Source" options={deviceList} onChange={(e, { value }) => { setFieldValue("src_id", value); }} />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>Starting Date (Optional)</label>
                                                <Form.Input value={values.date_start} type="date" name="date_start" onChange={handleChange} />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>Ending Date (Optional)</label>
                                                <Form.Input value={values.date_end} error={errors.date_end} type="date" name="date_end" onChange={handleChange} />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>File Format</label>
                                            </Form.Field>
                                            <Form.Field>
                                                <Radio onChange={() => { setFieldValue("format", "json") }} checked={values.format === "json"} label='JSON' value="json" control='input' type='radio' name='format' />    
                                            </Form.Field>
                                            <Form.Field>
                                                <Radio onChange={() => { setFieldValue("format", "csv") }} checked={values.format === "csv"} label='CSV' value="csv"  control='input' type='radio' name='format' />
                                            </Form.Field>
                                            <Form.Field>
                                                <Radio onChange={() => { setFieldValue("format", "tsv") }} checked={values.format === "tsv"} label='TSV' value="tsv" control='input' type='radio' name='format' />
                                            </Form.Field>
                                            <Form.Button type="submit" disabled={isSubmitting} loading={isSubmitting}>Download Dataset</Form.Button>
                                        </Form>
                                    )}
                                </Formik>
                            ) : (
                                <Message negative>
                                    <Message.Header>Unable to reach Project Amihan API Server</Message.Header>
                                    <p>We're sorry but our API server is currently unreachable. Please try again later.</p>
                                </Message>
                            )
                        ) : (
                            <Message>
                                <Message.Header>Loading</Message.Header>
                                <p>Connecting to API Server...</p>
                            </Message>
                        )}
                    </Grid.Column>
                </Grid.Row>
            </Grid>
            <p style={{ textAlign: 'center', paddingTop: '2rem' }}>Made with love in the Philippines by the Philippine Innovation Network</p>
        </Container>
    );
}

export default App;
