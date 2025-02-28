import React from 'react';
import { connect, UserSession } from '@stacks/connect';

const Header = () => {
  const userSession = new UserSession();

  const handleConnect = () => {
    connect({
      userSession,
      appDetails: {
        name: 'Decentralized Marketplace',
        icon: 'https://example.com/icon.png', // Replace with your app icon
      },
      onFinish: () => {
        window.location.reload(); // Reload the page after authentication
      },
    });
  };

  return (
    <nav>
      <h1>Decentralized Marketplace</h1>
      <button onClick={handleConnect}>Connect Wallet</button>
    </nav>
  );
};

export default Header;