import React from 'react';
import Header from './components/Header';
import ProductList from './components/ProductList';
import Profile from './components/Profile';
import './App.css';

const App = () => {
  const userAddress = 'your-user-address'; // Replace with actual user address

  return (
    <div className="App">
      <Header />
      <main>
        <ProductList />
        <Profile address={userAddress} />
      </main>
    </div>
  );
};

export default App;