import React, { useEffect, useState } from 'react';
import { Button, Container, Icon, Label, Table } from 'semantic-ui-react';
import { Link } from 'react-router-dom';

const server = process.env.REACT_APP_PROJECT_SERVER ? process.env.REACT_APP_PROJECT_SERVER : "";

export default function Dashboard({ user }) {
    let [ devices, setDevices ] = useState();
    useEffect(() => {
        fetch(`${server}/user/sensors`, {
                method: 'GET',
                headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': `Bearer ${window.localStorage.userToken}` }
            }).then(res => res.json())
            .then(data => data.map(x => {
                return (
                    <Table.Row key={x.src_id}>
                        <Table.Cell>
                            <Link to={`/device/${x.src_id}`}>{x.location_name}</Link>
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
        <Container fluid>
            <Table celled striped>
                <Table.Header>
                    <Table.Row>
                        <Table.HeaderCell colSpan='3'>Your Devices</Table.HeaderCell>
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
                <Table.Footer fullWidth>
                    <Table.Row>
                        <Table.HeaderCell colSpan='3'>
                            <Button floated='right' icon labelPosition='left' primary size='small'>
                                <Icon name='computer' /> Add a new Device
                            </Button>
                        </Table.HeaderCell>
                    </Table.Row>
                </Table.Footer>
            </Table>
        </Container>
    );
}