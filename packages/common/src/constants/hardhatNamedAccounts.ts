import { TNetworkNames } from '~common/models/TNetworkNames';

type TChain = TNetworkNames | number;
type TAccountName = 'deployer' | 'controller' | 'projects' | 'tokenStore';

/**
 * The default account to use for hardhat.  For example 0 will take by default take the first account of hardhat
 */
type TDefaultAccount = {
  ['default']: number | string;
};

/**
 * Named accounts to be used by hardaht.  See docs: https://github.com/wighawag/hardhat-deploy#1-namedaccounts-ability-to-name-addresses
 *
 * the values are account addresses, or account number in hardhat
 */
export const hardhatNamedAccounts: {
  [name in TAccountName]: Readonly<Partial<{ [network in TChain]: number | string }> & TDefaultAccount>;
} = {
  deployer: {
    default: 0, // here this will by default take the first account as deployer
  },
  controller: {
    default: '0x4e3ef8AFCC2B52E4e704f4c8d9B7E7948F651351',
    1: '0x4e3ef8AFCC2B52E4e704f4c8d9B7E7948F651351',
    4: '0xd96ecf0E07eB197587Ad4A897933f78A00B21c9a',
  },
  projects: {
    default: '0xD8B4359143eda5B2d763E127Ed27c77addBc47d3',
    1: '0xD8B4359143eda5B2d763E127Ed27c77addBc47d3',
    4: '0x2d8e361f8F1B5daF33fDb2C99971b33503E60EEE',
  },
  tokenStore: {
    default: '0xCBB8e16d998161AdB20465830107ca298995f371',
    1: '0xCBB8e16d998161AdB20465830107ca298995f371',
    4: '0x220468762c6cE4C05E8fda5cc68Ffaf0CC0B2A85',
  },
} as const;
