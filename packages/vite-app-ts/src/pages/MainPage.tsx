/* eslint-disable unused-imports/no-unused-vars-ts */
import '~~/styles/main-page.css';

import { GenericContract } from 'eth-components/ant/generic-contract';
import { useBalance, useEthersAdaptorFromProviderOrSigners } from 'eth-hooks';
import { useEthersAppContext } from 'eth-hooks/context';
import { useDexEthPrice } from 'eth-hooks/dapps';
import { asEthersAdaptor } from 'eth-hooks/functions';
import React, { FC, useEffect, useState } from 'react';
import { BrowserRouter, Switch } from 'react-router-dom';

import { createTabsAndRoutes, MainPageFooter, MainPageHeader, TContractPageList } from '../components/main';

import { useAppContracts, useConnectAppContracts, useLoadAppContracts } from '~common/components/context';
import { useCreateAntNotificationHolder } from '~common/components/hooks/useAntNotification';
import { useBurnerFallback } from '~common/components/hooks/useBurnerFallback';
import { useScaffoldAppProviders } from '~common/components/hooks/useScaffoldAppProviders';
import { useScaffoldHooksExamples } from '~~/components/hooks/useScaffoldHooksExamples';
import {
  BURNER_FALLBACK_ENABLED,
  CONNECT_TO_BURNER_AUTOMATICALLY,
  INFURA_ID,
  LOCAL_PROVIDER,
  MAINNET_PROVIDER,
  TARGET_NETWORK_INFO,
} from '~~/config/app.config';

/** ********************************
 * ⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️
 * See ./config/app.config.ts for configuration, such as TARGET_NETWORK
 * See ../common/src/config/appContracts.config.ts and ../common/src/config/externalContracts.config.ts to configure your contracts
 * See pageList variable below to configure your pages
 * See ../common/src/config/web3Modal.config.ts to configure the web3 modal
 * ⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️⛳️
 * ******************************** */

/**
 * The main component
 * @returns
 */
export const MainPage: FC = () => {
  const notificationHolder = useCreateAntNotificationHolder();
  // -----------------------------
  // Providers, signers & wallets
  // -----------------------------
  // 🛰 providers
  // see useLoadProviders.ts for everything to do with loading the right providers
  const scaffoldAppProviders = useScaffoldAppProviders({
    targetNetwork: TARGET_NETWORK_INFO,
    connectToBurnerAutomatically: CONNECT_TO_BURNER_AUTOMATICALLY,
    localProvider: LOCAL_PROVIDER,
    mainnetProvider: MAINNET_PROVIDER,
    infuraId: INFURA_ID,
  });

  // 🦊 Get your web3 ethers context from current providers
  const ethersAppContext = useEthersAppContext();

  // if no user is found use a burner wallet on localhost as fallback if enabled
  useBurnerFallback(scaffoldAppProviders, BURNER_FALLBACK_ENABLED);

  // -----------------------------
  // Load Contracts
  // -----------------------------
  // 🛻 load contracts
  useLoadAppContracts();
  // 🏭 connect to contracts for mainnet network & signer
  const [mainnetAdaptor] = useEthersAdaptorFromProviderOrSigners(MAINNET_PROVIDER);
  useConnectAppContracts(mainnetAdaptor);
  // 🏭 connec to  contracts for current network & signer
  useConnectAppContracts(asEthersAdaptor(ethersAppContext));

  // -----------------------------
  // Hooks use and examples
  // -----------------------------
  // 🎉 Console logs & More hook examples:
  // 🚦 disable this hook to stop console logs
  // 🏹🏹🏹 go here to see how to use hooks!
  useScaffoldHooksExamples(scaffoldAppProviders);

  // -----------------------------
  // These are the contracts!
  // -----------------------------

  // init contracts
  const governorFactory = useAppContracts('JBGovernorFactory', ethersAppContext.chainId);
  const testProjectFactory = useAppContracts('JBTestProjectFactory', ethersAppContext.chainId);

  // -----------------------------
  // .... 🎇 End of examples
  // -----------------------------
  // 💵 This hook will get the price of ETH from 🦄 Uniswap:
  const [ethPrice] = useDexEthPrice(
    scaffoldAppProviders.mainnetAdaptor?.provider,
    ethersAppContext.chainId !== 1 ? scaffoldAppProviders.targetNetwork : undefined
  );

  // 💰 this hook will get your balance
  const [yourCurrentBalance] = useBalance(ethersAppContext.account);

  const [route, setRoute] = useState<string>('');
  useEffect(() => {
    setRoute(window.location.pathname);
  }, [setRoute]);

  // -----------------------------
  // 📃 App Page List
  // -----------------------------
  // This is the list of tabs and their contents
  const pageList: TContractPageList = {
    mainPage: {
      name: 'JBGovernorFactory',
      content: (
        <GenericContract
          contractName="JBGovernorFactory"
          contract={governorFactory}
          mainnetAdaptor={scaffoldAppProviders.mainnetAdaptor}
          blockExplorer={scaffoldAppProviders.targetNetwork.blockExplorer}
        />
      ),
    },
    pages: [
      {
        name: 'Create Test Project',
        content: (
          <GenericContract
            contractName="JBTestProjectFactory"
            contract={testProjectFactory}
            mainnetAdaptor={scaffoldAppProviders.mainnetAdaptor}
            blockExplorer={scaffoldAppProviders.targetNetwork.blockExplorer}
          />
        ),
      },
    ],
  };
  const { routeContent: tabContents, tabMenu } = createTabsAndRoutes(pageList, route, setRoute);

  // -----------------------------
  // 📃 Render the react components
  // -----------------------------

  return (
    <div className="App">
      <MainPageHeader scaffoldAppProviders={scaffoldAppProviders} price={ethPrice} />
      {/* Routes should be added between the <Switch> </Switch> as seen below */}
      <BrowserRouter>
        {tabMenu}
        <Switch>
          {tabContents}
          {/* Subgraph also disabled in MainPageMenu, it does not work, see github issue https://github.com/scaffold-eth/scaffold-eth-typescript/issues/48! */}
          {/*
          <Route path="/subgraph">
            <Subgraph subgraphUri={subgraphUri} mainnetProvider={scaffoldAppProviders.mainnetAdaptor?.provider} />
          </Route>
          */}
        </Switch>
      </BrowserRouter>

      <MainPageFooter scaffoldAppProviders={scaffoldAppProviders} price={ethPrice} />
      <div style={{ position: 'absolute' }}>{notificationHolder}</div>
    </div>
  );
};
