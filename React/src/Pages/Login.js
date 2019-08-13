import React, { useState } from 'react';
import { Button, Divider, Form, Grid, Message, Segment } from 'semantic-ui-react';
import { Link, withRouter } from 'react-router-dom';
import { Formik } from 'formik';

function Login({ history }) {
    let [loading, setLoading] = useState(false);
    let [loadingIndicator, setLoadingIndicator] = useState(false);
    return (
        <React.Fragment>
            {loading && (
                <Message positive={loading.positive} negative={loading.negative} info={loading.info} content={loading.message} />
            )}
            <Segment basic>
                <Grid columns={2} relaxed="very">
                    <Grid.Column>
                        <React.Fragment>
                            <h1>Login to Project Amihan</h1>
                            <p>If you would like to contribute to the Project Amihan dataset, please login to configure your devices in our cluster.</p>
                            <Formik
                                initialValues={{email: '', password: ''}}
                                validate={values => {
                                    let errors = {};
                                    if (!values.email) errors.email = "Please enter your email address.";
                                    else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(values.email)) errors.email = "This is not a valid email address.";
                                    if (values.password.length < 6) errors.password = "Passwords must be 6 characters long."
                                    return errors;
                                }}
                                onSubmit={(values, actions) => {
                                    setLoadingIndicator(true);
                                    setLoading({message: `Logging in to ${values.email}'s account.`, positive: false, negative: false, info: true});
                                    fetch(`http://amihan.local/auth/login`, {
                                        method: 'POST',
                                        headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
                                        body: JSON.stringify(values)
                                    }).then(res => res.json()).then(res => {
                                        if (res.token) {
                                            setLoading({message: `Account successfully logged in.`, positive: true, negative: false, info: false});
                                            window.localStorage.setItem('userToken', res.token);
                                            window.localStorage.setItem('userEmail', res.email);
                                            window.localStorage.setItem('userName', res.name);
                                            history.push('/');
                                        }
                                        else {
                                            setLoading({message: res.message, positive: false, negative: true, info: false});
                                            setLoadingIndicator(false);
                                            actions.setSubmitting(false);
                                        }
                                    });
                                }}
                            >
                                {({ values, errors, handleChange, handleSubmit, isSubmitting }) => (
                                    <React.Fragment>
                                        <Form>
                                            <Form.Field>
                                                <label>Email Address</label>
                                                <Form.Input onChange={handleChange} error={errors.email} value={values.email} placeholder="hello@world.net" type="email" name="email" required />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>Password</label>
                                                <Form.Input onChange={handleChange} error={errors.password} value={values.password} placeholder="Password (at least 6 characters)" type="password" name="password" required />
                                                <Link to="/forgot">Forgot Password?</Link>
                                            </Form.Field>
                                            <Button color="orange" type="submit" disabled={isSubmitting || loadingIndicator || Object.keys(errors).length > 0} loading={isSubmitting || loadingIndicator} onClick={handleSubmit} fluid>Login</Button>
                                        </Form>
                                    </React.Fragment>
                                )}
                            </Formik>
                        </React.Fragment>
                    </Grid.Column>
                    <Grid.Column>
                    <React.Fragment>
                            <h1>Create an Account</h1>
                            <p>If you would like to contribute to the Project Amihan dataset, please create an account to setup your devices to be added to our cluster.</p>
                            <Formik
                                initialValues={{email: '', password: '', confirm: '', name: ''}}
                                validate={values => {
                                    let errors = {};
                                    if (!values.name) errors.name = "Please enter your name.";
                                    if (values.name === values.email) errors.name = "Please do not enter your email address as your name.";
                                    if (!values.email) errors.email = "Please enter your email.";
                                    else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(values.email)) errors.email = "This is not a valid email address.";
                                    if (values.password.length < 6) errors.password = "Passwords must be 6 characters long.";
                                    if (values.password !== values.confirm) errors.confirm = "Please confirm your password."
                                    return errors;
                                }}
                                onSubmit={(values, actions) => {
                                    setLoadingIndicator(true);
                                    setLoading({message: `Logging in to ${values.email}'s account.`, positive: false, negative: false, info: true});
                                    fetch(`http://amihan.local/auth/register`, {
                                        method: 'POST',
                                        headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
                                        body: JSON.stringify(values)
                                    }).then(res => res.json()).then(res => {
                                        if (res.token) {
                                            setLoading({message: `Account successfully logged in.`, positive: true, negative: false, info: false});
                                            window.localStorage.setItem('userToken', res.token);
                                            window.localStorage.setItem('userEmail', res.email);
                                            window.localStorage.setItem('userName', res.name);
                                            history.push('/');
                                        }
                                        else {
                                            setLoading({message: res.message, positive: false, negative: true, info: false});
                                            setLoadingIndicator(false);
                                            actions.setSubmitting(false);
                                        }
                                    });
                                }}
                            >
                                {({ values, errors, handleChange, handleSubmit, isSubmitting }) => (
                                    <React.Fragment>
                                        <Form>
                                            <Form.Field>
                                                <label>Name</label>
                                                <Form.Input onChange={handleChange} error={errors.name} value={values.name} placeholder="Your name here" type="text" name="name" required />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>Email Address</label>
                                                <Form.Input onChange={handleChange} error={errors.email} value={values.email} placeholder="hello@world.net" type="email" name="email" required />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>Password</label>
                                                <Form.Input onChange={handleChange} error={errors.password} value={values.password} placeholder="Password (at least 6 characters)" type="password" name="password" required />
                                            </Form.Field>
                                            <Form.Field>
                                                <label>Confirm Password</label>
                                                <Form.Input onChange={handleChange} error={errors.confirm} value={values.confirm} placeholder="Password (at least 6 characters)" type="password" name="confirm" required />
                                            </Form.Field>
                                            <Button color="green" type="submit" disabled={isSubmitting || loadingIndicator || Object.keys(errors).length > 0} loading={isSubmitting || loadingIndicator} onClick={handleSubmit} fluid>Create an account</Button>
                                        </Form>
                                    </React.Fragment>
                                )}
                            </Formik>
                        </React.Fragment>
                    </Grid.Column>
                </Grid>
                <Divider vertical>OR</Divider>
            </Segment>
        </React.Fragment>
    );
}

export default withRouter(Login);
