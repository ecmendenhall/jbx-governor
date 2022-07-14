import { DeployFunction } from 'hardhat-deploy/types';
import { THardhatRuntimeEnvironmentExtended } from 'helpers/types/THardhatRuntimeEnvironmentExtended';

const func: DeployFunction = async (hre: THardhatRuntimeEnvironmentExtended) => {
  const { getNamedAccounts, deployments } = hre;
  const { deploy } = deployments;
  const { deployer, controller, projects, tokenStore } = await getNamedAccounts();

  console.log('JBTestProjectFactory...');
  await deploy('JBTestProjectFactory', {
    from: deployer,
    args: [controller, projects, tokenStore],
    log: true,
  });
};
export default func;
func.tags = ['JBTestProjectFactory'];
