import React from 'react';
import { Menu } from 'semantic-ui-react';
import { withRouter } from 'react-router-dom';

function AdminNavBar({ history, current }) {
    return (
        <Menu fluid vertical tabular>
            <Menu.Item name='System Information' onClick={() => history.push("/administration")} active={current===1} />
            <Menu.Item name='Account Management' onClick={() => history.push("/administration/accounts")} active={current===2} />
            <Menu.Item name='Device Management' onClick={() => history.push("/administration/devices")} active={current===3} />
        </Menu>
    );
}

export default withRouter(AdminNavBar);
