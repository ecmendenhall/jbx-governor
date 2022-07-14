# 🍌 ~~Fully~~ Partially Automated Luxury Juicebox Governance 🧃

A factory contract for deploying an `ERC20Votes` token, governor, and timelock to manage a Juicebox project. A submission to the Juicebox/Scaffold ETH hackathon.

The `JBGovernorFactory` contract deploys a standard [OpenZeppelin Governor](https://blog.openzeppelin.com/governor-smart-contract/) stack (voting token, governor and timelock), swaps your Juicebox project token for a governance-compatible `JBVotesToken`, and transfers ownership of your project token to a timelock controller. Your Juicebox project ERC20s can now be used to govern Juicebox project parameters, rather than relying on a trusted admin who owns the project NFT.

This is in pretty rough shape, but a good example of how a factory contract could work for this purpose. Given more time, I'd add:

- A better frontend for creating a new governance stack.
- Clones rather than direct contract deployments to reduce the gas costs of deploying all the necessary contracts.
