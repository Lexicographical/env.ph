import React from 'react';
import { Container } from 'semantic-ui-react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Main from './Pages/Main';
import Login from './Pages/Login';
import Error404 from './Pages/Error404';
import Header from './Components/Header';
import Footer from './Components/Footer';

function App() {
    return (
        <Container fluid style={{ padding: '4rem' }}>
            <Router>
                <Header />
                <Switch>
                    <Route path="/" exact component={Main} />
                    <Route path="/login" exact component={Login} />
                    <Route component={Error404} />
                </Switch>
                <Footer />
            </Router>
        </Container>
    );
}

export default App;
