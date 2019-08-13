import React from 'react';
import { withRouter, Link } from 'react-router-dom';
import { Menu } from 'semantic-ui-react';

function Header({ history }) {
    return (
        <React.Fragment>
            <Menu secondary style={{ paddingBottom: '2rem' }}>
            <Link to="/"><img src="/logo.png" alt="Project Amihan" style={{ maxWidth: '576px', maxHeight: '128px' }} /></Link>
                <Menu.Menu position='right'>
                    {window.localStorage.userToken ? (
                        <React.Fragment>
                            <Menu.Item content={`Logged in as ${window.localStorage.userName} (${window.localStorage.userEmail})`} />
                            <Menu.Item
                                content="Logout"
                                style={{ color: '#4183c4' }}
                                onClick={() => {window.localStorage.removeItem('userToken');history.push("/login")}}
                            />
                        </React.Fragment>
                    ) : (
                        <Menu.Item
                            content="Login"
                            style={{ color: '#4183c4' }}
                            onClick={() => history.push("/login")}
                        />
                    )}
                </Menu.Menu>
            </Menu>
        </React.Fragment>
    );
}

export default withRouter(Header);
