import React, { useEffect, useState } from 'react';
import { Button, Container, Form, Icon, Label, Message, Modal, Table } from 'semantic-ui-react';
import { Link } from 'react-router-dom';
import { Formik } from 'formik';

const server = process.env.REACT_APP_PROJECT_SERVER ? process.env.REACT_APP_PROJECT_SERVER : "";

function Dashboard({ user }) {
    let [ devices, setDevices ] = useState();
    let [ loading, setLoading ] = useState(false);
    let [ modalOpen, setModalOpen ] = useState(false);
    useEffect(() => {
        fetch(`${server}/user/sensors`, {
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
    }, [user, loading]);
    return (
        <Container fluid>
            <Table celled striped selectable>
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
                            <Formik
                                initialValues={{name: ''}}
                                validate={values => {
                                    let errors = {};
                                    if (values.name.length < 6) errors.name = "Location must be 6 characters long."
                                    return errors;
                                }}
                                onSubmit={(values, actions) => {
                                    setLoading({message: `Adding device located at ${values.name}.`, positive: false, negative: false, info: true});
                                    fetch(`${server}/user/create/sensor`, {
                                        method: 'POST',
                                        headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': `Bearer ${window.localStorage.userToken}` },
                                        body: JSON.stringify(values)
                                    }).then(res => {
                                        if (res.status === 204) {
                                            setLoading({message: `Device successfully added.`, positive: true, negative: false, info: false});
                                            setModalOpen(false);
                                        }
                                        else {
                                            let m = res.json();
                                            setLoading({message: m.message, positive: false, negative: true, info: false});
                                            actions.setSubmitting(false);
                                        }
                                    });
                                }}
                            >
                                {({ values, errors, handleChange, handleSubmit, isSubmitting }) => (
                                    <Modal 
                                        trigger={
                                            <Button floated='right' icon labelPosition='left' primary size='small' onClick={() => setModalOpen(true)}>
                                                <Icon name='computer' /> Add a new Device
                                            </Button>
                                        }
                                        open={modalOpen}
                                        closeOnDimmerClick={!isSubmitting}
                                        closeOnEscape={!isSubmitting}
                                        centered={false}
                                        closeIcon={!isSubmitting}
                                    >
                                        <Modal.Header>Add a new Device</Modal.Header>
                                        <Modal.Content>
                                            <Modal.Description>
                                                {loading && (
                                                    <Message positive={loading.positive} negative={loading.negative} info={loading.info} content={loading.message} />
                                                )}
                                                <Form>
                                                    <Form.Field>
                                                        <label>Location of Device</label>
                                                        <Form.Input onChange={handleChange} error={errors.name} value={values.name} placeholder="1 Roxas Bvld. Manila, Philippines" type="text" name="name" required />
                                                    </Form.Field>
                                                    <Button color="green" type="submit" disabled={isSubmitting || Object.keys(errors).length > 0} loading={isSubmitting} onClick={handleSubmit} fluid>Add Device</Button>
                                                </Form>
                                            </Modal.Description>
                                        </Modal.Content>
                                    </Modal>
                                )}
                            </Formik>
                        </Table.HeaderCell>
                    </Table.Row>
                </Table.Footer>
            </Table>
        </Container>
    );
}

export default Dashboard;