import { DeployFunction } from 'hardhat-deploy/types';
import { THardhatRuntimeEnvironmentExtended } from 'helpers/types/THardhatRuntimeEnvironmentExtended';

const func: DeployFunction = async (hre: THardhatRuntimeEnvironmentExtended) => {
  const { getNamedAccounts, deployments } = hre;
  const { deploy } = deployments;
  const { deployer, controller, projects, tokenStore } = await getNamedAccounts();

  console.log('DeployToken...');
  const deployToken = await deploy('DeployToken', {
    from: deployer,
    log: true,
  });

  console.log('DeployTimelock...');
  const deployTimelock = await deploy('DeployTimelock', {
    from: deployer,
    log: true,
  });

  console.log('DeployGovernor...');
  const deployGovernor = await deploy('DeployGovernor', {
    from: deployer,
    log: true,
  });

  console.log('JBGovernorFactory...');
  await deploy('JBGovernorFactory', {
    from: deployer,
    args: [controller, projects, tokenStore],
    libraries: {
      DeployToken: deployToken.address,
      DeployTimelock: deployTimelock.address,
      DeployGovernor: deployGovernor.address,
    },
    log: true,
  });

  /*
    // Getting a previously deployed contract
    const YourContract = await ethers.getContract("YourContract", deployer);
    await YourContract.setPurpose("Hello");

    //const yourContract = await ethers.getContractAt('YourContract', "0xaAC799eC2d00C013f1F11c37E654e59B0429DF6A") //<-- if you want to instantiate a version of a contract at a specific address!
  */
};
export default func;
func.tags = ['JBGovernorFactory'];
