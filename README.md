# 🍌 ~~Fully~~ Partially Automated Luxury Juicebox Governance 🧃

A factory contract for deploying an `ERC20Votes` token, governor, and timelock to manage a Juicebox project. A submission to the Juicebox/Scaffold ETH hackathon.

The `JBGovernorFactory` contract deploys a standard [OpenZeppelin Governor](https://blog.openzeppelin.com/governor-smart-contract/) stack (voting token, governor and timelock), swaps your Juicebox project token for a governance-compatible `JBVotesToken`, and transfers ownership of your project token to a timelock controller. Your Juicebox project ERC20s can now be used to govern Juicebox project parameters, rather than relying on a trusted admin who owns the project NFT.

This is in pretty rough shape, but a good example of how a factory contract could work for this purpose. Given more time, I'd add:

- A better frontend for creating a new governance stack.
- Clones rather than direct contract deployments to reduce the gas costs of deploying all the necessary contracts.

You can see an example DAO created with these contracts [here](https://www.tally.xyz/governance/eip155:4:0xB813B5aD8a39b0eC03Df7D61dDE49C17CD4Ea961) on Tally. Don't use this in production, but I hope it's a useful example of how a successful JB project might decentralize itself using off the shelf tools.
