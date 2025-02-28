import React, { useEffect, useState } from 'react';
import { callReadOnlyFunction } from '@stacks/transactions';

const ProductDetail = ({ productId }) => {
  const [product, setProduct] = useState(null);

  useEffect(() => {
    const fetchProduct = async () => {
      const response = await callReadOnlyFunction({
        contractAddress: 'your-contract-address',
        contractName: 'your-contract-name',
        functionName: 'get-product-details',
        functionArgs: [productId],
        senderAddress: 'your-sender-address',
        network: 'testnet', // or 'mainnet'
      });
      setProduct(response);
    };
    fetchProduct();
  }, [productId]);

  if (!product) return <div>Loading...</div>;

  return (
    <div>
      <h2>{product.title}</h2>
      <p>{product.description}</p>
      <p>Price: {product.price} STX</p>
      <button>Purchase</button>
    </div>
  );
};

export default ProductDetail;