import React, { useEffect, useState } from 'react';
import { fetchCallReadOnlyFunction, Cl } from '@stacks/transactions';

const ProductList = () => {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetchCallReadOnlyFunction({
          contractAddress: 'your-contract-address',
          contractName: 'your-contract-name',
          functionName: 'get-all-products',
          functionArgs: [], // No arguments needed for this function
          senderAddress: 'your-sender-address',
          network: 'testnet', // or 'mainnet'
        });
        setProducts(response);
      } catch (error) {
        console.error('Error fetching products:', error);
      }
    };
    fetchProducts();
  }, []);

  return (
    <div>
      <h2>Products</h2>
      <ul>
        {products.map((product, index) => (
          <li key={index}>
            <h3>{product.title}</h3>
            <p>{product.description}</p>
            <p>Price: {product.price} STX</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ProductList;