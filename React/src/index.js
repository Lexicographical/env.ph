import React from 'react';
import { render } from 'react-snapshot';
import 'semantic-ui-css/semantic.min.css';
import App from './App';
import * as serviceWorker from './serviceWorker';
import ReactGA from 'react-ga';

ReactGA.initialize('UA-145147538-1');
ReactGA.pageview(window.location.pathname + window.location.search);

render(<App />, document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
