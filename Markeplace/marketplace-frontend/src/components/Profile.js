import React, { useEffect, useState } from 'react';
import { fetchCallReadOnlyFunction, Cl } from '@stacks/transactions';

const Profile = ({ address }) => {
  const [profile, setProfile] = useState(null);
  const [reputation, setReputation] = useState(0);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const profileResponse = await fetchCallReadOnlyFunction({
          contractAddress: 'your-contract-address',
          contractName: 'your-contract-name',
          functionName: 'get-member-profile',
          functionArgs: [Cl.principal(address)], // Serialize address as a Clarity principal
          senderAddress: 'your-sender-address',
          network: 'testnet', // or 'mainnet'
        });
        setProfile(profileResponse);

        const reputationResponse = await fetchCallReadOnlyFunction({
          contractAddress: 'your-contract-address',
          contractName: 'your-contract-name',
          functionName: 'get-reputation',
          functionArgs: [Cl.principal(address)], // Serialize address as a Clarity principal
          senderAddress: 'your-sender-address',
          network: 'testnet', // or 'mainnet'
        });
        setReputation(reputationResponse.score);
      } catch (error) {
        console.error('Error fetching profile:', error);
      }
    };
    fetchProfile();
  }, [address]);

  if (!profile) return <div>Loading...</div>;

  return (
    <div>
      <h2>Profile</h2>
      <p>Role: {profile.role}</p>
      <p>Status: {profile.status}</p>
      <p>Reputation: {reputation}</p>
    </div>
  );
};

export default Profile;