import React, { useState, useEffect } from 'react';
import { Card, Grid, Form, Message, Radio } from 'semantic-ui-react';
import { Formik } from 'formik';
import { Map, Marker, Popup, TileLayer } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import Highcharts from 'highcharts';
import HighChartsData from "highcharts/modules/data";
import HighChartsNoData from "highcharts/modules/no-data-to-display";
import HighchartsReact from 'highcharts-react-official';

HighChartsData(Highcharts);
HighChartsNoData(Highcharts);

const server = process.env.REACT_APP_PROJECT_SERVER ? process.env.REACT_APP_PROJECT_SERVER : "";

const pointerIcon = new L.Icon({
    iconUrl: require('../amihan.png'),
    iconRetinaUrl: require('../amihan.png'),
    iconSize: [50,50],
});

export default function Main() {
    let [ deviceList, setDeviceList ] = useState(null);
    let [ locations, setLocations ] = useState(null);
    let [ selected, setSelected ] = useState(null);
    useEffect(() => { 
        fetch(`${server}/query/list`).then(res => res.json()).then(list => {
            setDeviceList(list.sensors.map(x => {
                return {
                    key: x.src_id,
                    text: x.location_name,
                    value: x.src_id
                }
            }));
            setLocations(list.sensors.map(x => {
                if (x.latitude === null || x.longitude === null) return null;
                else return (
                    <Marker key={x.src_id} position={[x.latitude, x.longitude]} icon={pointerIcon}>
                        <Popup onOpen={()=>setSelected(x.src_id)} onClose={()=>setSelected(null)}>
                            {x.location_name}
                        </Popup>
                    </Marker>
                );
            }));
        }).catch(() => {setDeviceList(false)});    
    }, []);
    return (
        <React.Fragment>
            <Grid>
                <Grid.Row>
                    <Grid.Column computer={12} tablet={16} mobile={16} >
                        <Map center={[16.0287167,121.665402]} zoom={7} style={{height: '40vh', width: '100%'}}>
                            <TileLayer
                                url="https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png"
                                attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.'
                            />
                            {locations}
                        </Map>
                    </Grid.Column>
                    <Grid.Column computer={4} tablet={16} mobile={16}>
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
                                        window.location.href=`${server}/query/data?src_id=${values.src_id}&date_start=${values.date_start}&date_end=${values.date_end}&format=${values.format}`;
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
            <br />
            <Grid>
                <Grid.Row>
                    {selected && (
                        <React.Fragment>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'PM 1.0 (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/pm1?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'PM 1.0'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'PM 2.5 (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/pm25?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'PM 2.5'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'PM 10 (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/pm10?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'PM 10'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'Humidity (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/humidity?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'Humidity'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'Temperature (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/temperature?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'Temperature'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'MQ-135 (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/voc?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'MQ-135'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                            <Grid.Column widescreen={4} computer={8} tablet={8} mobile={16}>
                                <center>
                                    <Card style={styles.embedCard}>
                                        <HighchartsReact
                                            highcharts={Highcharts}
                                            options={{
                                                title: {
                                                    text: 'MQ-7 (24 Hours Result)'
                                                },
                                                credits: {enabled: false},
                                                data: {
                                                    rowsURL: `${server}/query/sensor/carbonMonoxide?src_id=${selected}`,
                                                    enablePolling: false,
                                                    firstRowAsNames: false,
                                                },
                                                series: [{name: 'MQ-7'}]
                                            }}
                                        />
                                    </Card>
                                </center>
                            </Grid.Column>
                        </React.Fragment>
                    )}
                </Grid.Row>
            </Grid>
        </React.Fragment>
    );
}

const styles = {
    embedCard: {
        width: '450px', 
        marginTop: '2rem'
    },
    embedIframe: {
        border: 'none', 
        width: '450px', 
        height: '260px',
    }
}
