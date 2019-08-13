import React from 'react';
import MessengerCustomerChat from 'react-messenger-customer-chat';

export default function Footer() {
    return (
        <React.Fragment>
            <br />
            <center>
                <a style={{ paddingTop: '2rem' }} href="https://github.com/TeamOjt/Air-Quality-Monitoring-System">Are you a DIYer? Assemble your own Air Quality Station and help us contribute to the dataset!</a>
                <p style={{ paddingTop: '2rem' }}>Made with love in the Philippines by the <a href="https://github.com/ph-innovation-network">Philippine Innovation Network</a></p>
            </center>
            <MessengerCustomerChat 
                pageId="107222663954974"
                themeColor="#63AABD"
                appId=""
            />
        </React.Fragment>
    );
}
