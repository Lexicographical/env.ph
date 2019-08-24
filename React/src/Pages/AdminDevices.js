import React, { useState, useEffect } from 'react';
import { Grid, Label, Table } from 'semantic-ui-react';
import { Link } from 'react-router-dom';
import AdminNavBar from '../Components/AdminNavBar';

const server = process.env.REACT_APP_PROJECT_SERVER ? process.env.REACT_APP_PROJECT_SERVER : "";

function AdminDevices({ user }) {
    let [ devices, setDevices ] = useState();
    useEffect(() => {
        fetch(`${server}/admin/sensors`, {
                method: 'GET',
                headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': `Bearer ${window.localStorage.userToken}` }
            }).then(res => res.json())
            .then(data => data.map(x => {
                return (
                    <Table.Row key={x.src_id}>
                        <Table.Cell selectable>
                            <Link to={`/device/${x.src_id}`} style={{ color: '#4183c4' }}>{x.location_name}</Link>
                        </Table.Cell>
                        <Table.Cell>{x.last_contact}</Table.Cell>
                        <Table.Cell>
                            <Label color={x.status_color} horizontal>{x.status}</Label>
                        </Table.Cell>
                    </Table.Row>
                );
            })).then(setDevices);
    }, [user]);
    return (
        <React.Fragment>
            <Grid>
                <Grid.Row>
                    <Grid.Column width={4}>
                        <AdminNavBar current={3} />
                    </Grid.Column>
                    <Grid.Column width={12}>
                        <React.Fragment>
                            <h1>Devices Management</h1>
                            <Table celled striped selectable>
                                <Table.Header>
                                    <Table.Row>
                                        <Table.HeaderCell colSpan='3'>Devices in the Project Amihan Platform</Table.HeaderCell>
                                    </Table.Row>
                                    <Table.Row>
                                        <Table.HeaderCell>Location</Table.HeaderCell>
                                        <Table.HeaderCell>Last Contact</Table.HeaderCell>
                                        <Table.HeaderCell>Status</Table.HeaderCell>
                                    </Table.Row>
                                </Table.Header>
                                <Table.Body>
                                    {devices}
                                </Table.Body>
                            </Table>
                        </React.Fragment>
                    </Grid.Column>
                </Grid.Row>
            </Grid>
        </React.Fragment>
    );
}

export default AdminDevices;