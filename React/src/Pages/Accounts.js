import React, { useEffect, useState } from 'react';
import { Button, Grid, Table } from 'semantic-ui-react';
import AdminNavBar from '../Components/AdminNavBar';
import { withRouter } from 'react-router-dom';
const server = process.env.REACT_APP_PROJECT_SERVER ? process.env.REACT_APP_PROJECT_SERVER : "";

function Accounts({ history }) {
    let [ accounts, setAccounts ] = useState();
    useEffect(() => {
        fetch(`${server}/admin/users`, {
            method: 'GET',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': `Bearer ${window.localStorage.userToken}` }
        }).then(res => {
            if (res.status !== 200) history.push('/dashboard');
            return res.json();
        }).then(users => users.map(user => {
            return (
                <Table.Row>
                    <Table.Cell>{user.name}</Table.Cell>
                    <Table.Cell>{user.email}</Table.Cell>
                    <Table.Cell>{user.type === "admin" ? "Administrator" : "Standard User"}</Table.Cell>
                    <Table.Cell>
                        {window.localStorage.userEmail !== user.email && (
                            user.type !== "admin" ? (
                                <Button color="blue">Promote {user.name} to Administrator</Button>
                            ) : (
                                <Button color="red">Remove Administrator Privileges for {user.name}</Button>
                            )
                        )}
                    </Table.Cell>
                </Table.Row>
            );
        })).then(setAccounts);
    }, [ history ]);
    return (
        <React.Fragment>
            <Grid>
                <Grid.Row>
                    <Grid.Column width={4}>
                        <AdminNavBar current={2} />
                    </Grid.Column>
                    <Grid.Column width={12}>
                        <React.Fragment>
                            <h1>Accounts Management</h1>
                            <Table celled striped selectable>
                                <Table.Header>
                                    <Table.Row>
                                        <Table.HeaderCell>Name</Table.HeaderCell>
                                        <Table.HeaderCell>Email Address</Table.HeaderCell>
                                        <Table.HeaderCell>Account Type</Table.HeaderCell>
                                        <Table.HeaderCell>Promote to Administrator</Table.HeaderCell>
                                    </Table.Row>
                                </Table.Header>
                                <Table.Body>{accounts}</Table.Body>
                            </Table>
                        </React.Fragment>
                    </Grid.Column>
                </Grid.Row>
            </Grid>
        </React.Fragment>
    );
}

export default withRouter(Accounts);