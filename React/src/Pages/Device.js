import React, { useState, useEffect } from 'react';
import { Button, Card, Grid, Icon, Label, Message } from 'semantic-ui-react';
import { Link, withRouter } from 'react-router-dom';
import { Map, Marker, TileLayer } from 'react-leaflet';
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

function Device({ user, match, history }) {
    let [ device, setDevice ] = useState();
    useEffect(() => {
        fetch(`${server}/user/sensor/${match.params.id}`, {
            method: 'GET',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': `Bearer ${window.localStorage.userToken}` }
        }).then(res => {
            if (res.status !== 200) history.push('/dashboard');
            return res.json()
        }).then(setDevice);
    }, [ user, match, history ]);
    return (
        <React.Fragment>
            <h1>Device Information</h1>
            {device ? (
                <React.Fragment>
                    <Grid columns={2} divided stackable>
                        <Grid.Column >
                            <Map center={[device.latitude, device.longitude]} zoom={14} style={{height: '40vh', width: '100%'}}>
                                <TileLayer
                                    url="https://stamen-tiles.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png"
                                    attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.'
                                />
                                <Marker position={[device.latitude, device.longitude]} icon={pointerIcon} />
                            </Map>
                        </Grid.Column>
                        <Grid.Column>
                            <h2>{device.location_name} <Label color={device.status_color} horizontal>{device.status}</Label></h2>
                            <p>Created at <b>{device.creation_time}</b></p>
                            <p>Device last contacted our server on <b>{device.last_contact}</b></p>
                            <h4>Device API Key:</h4>
                            <Message warning>{device.api_key || "No Device API Key Available. Please contact us for assistance."}</Message>
                        </Grid.Column>
                    </Grid>
                    <Grid>
                        <Grid.Row>
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
                                                        rowsURL: `${server}/query/sensor/pm1?src_id=${match.params.id}`,
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
                                                        rowsURL: `${server}/query/sensor/pm25?src_id=${match.params.id}`,
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
                                                        rowsURL: `${server}/query/sensor/pm10?src_id=${match.params.id}`,
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
                                                        rowsURL: `${server}/query/sensor/humidity?src_id=${match.params.id}`,
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
                                                        rowsURL: `${server}/query/sensor/temperature?src_id=${match.params.id}`,
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
                                                        rowsURL: `${server}/query/sensor/voc?src_id=${match.params.id}`,
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
                                                        rowsURL: `${server}/query/sensor/carbonMonoxide?src_id=${match.params.id}`,
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
                        </Grid.Row>
                    </Grid>
                    <br />
                    <Link to="/dashboard">
                        <Button icon labelPosition='left'>
                            <Icon name='left arrow' />
                            Back to Dashboard
                        </Button>
                    </Link>
                </React.Fragment>
            ) : (<h3>Loading...</h3>)}
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

export default withRouter(Device);
