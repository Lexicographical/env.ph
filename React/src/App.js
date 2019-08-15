import React from 'react';
import { Container } from 'semantic-ui-react';
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom';
import Main from './Pages/Main';
import Login from './Pages/Login';
import Dashboard from './Pages/Dashboard';
import Device from './Pages/Device';
import Error404 from './Pages/Error404';
import Header from './Components/Header';
import Footer from './Components/Footer';

const server = process.env.REACT_APP_PROJECT_SERVER ? process.env.REACT_APP_PROJECT_SERVER : "";

function PrivateRoute({component: Component, ...rest}) {
    return (
        <Route
            {...rest}
            render={props => window.localStorage.userToken ? (<Component {...props} />) : (<Redirect to="/login" />)}
        />
    )
}

function PublicRoute({component: Component, onUserLogin, ...rest}) {
    return (
        <Route
            {...rest}
            render={props => !window.localStorage.userToken ? (<Component {...props} onUserLogin={onUserLogin} />) : (<Redirect to="/" />)}
        />
    )
}

function AdminRoute({component: Component, user, ...rest}) {
    if (!window.localStorage.userToken) return (<Redirect to="/login" />);
    else if (user.type !== "admin") return (<Redirect to="/" />);
    else return (<Route {...rest} user={user} component={Component} />);
}

function App() {
    let [user, setUser] = React.useState(false);
    let [loggedIn, setLoggedIn] = React.useState(window.localStorage.userToken !== undefined);
    React.useEffect(() => {
        if (loggedIn) {
            fetch(`${server}/auth/verify`, {
                method: 'GET',
                headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': `Bearer ${window.localStorage.userToken}` }
            }).then(res => res.json()).then(setUser);
        }
    }, [loggedIn]);
    return (
        <Container fluid style={{ padding: '4rem' }}>
            <Router>
                <Header user={user} onUserLogout={setLoggedIn} />
                <Switch>
                    <Route path="/" exact component={Main} />
                    <PublicRoute path="/login" exact component={Login} onUserLogin={setLoggedIn} />
                    <PrivateRoute path="/dashboard" exact component={Dashboard} user={user} />
                    <PrivateRoute path="/device/:id" exact component={Device} user={user} />
                    <AdminRoute path="/administration" exact component={Dashboard} user={user} />
                    <Route component={Error404} />
                </Switch>
                <Footer />
            </Router>
        </Container>
    );
}

export default App;
