import React from 'react';
import { Grid } from 'semantic-ui-react';
import AdminNavBar from '../Components/AdminNavBar';

function Administration() {
    return (
        <React.Fragment>
            <Grid>
                <Grid.Row>
                    <Grid.Column width={4}>
                        <AdminNavBar current={1} />
                    </Grid.Column>
                    <Grid.Column width={12}>
                        <React.Fragment>
                            <h1>System Logs</h1>
                            <p>Placeholder for logs content.</p>
                        </React.Fragment>
                    </Grid.Column>
                </Grid.Row>
            </Grid>
        </React.Fragment>
    );
}

export default Administration;