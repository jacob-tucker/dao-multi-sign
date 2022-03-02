import './App.css';
import {useEffect, useState} from 'react';
import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";
import { createManager, executeAction, getIntents, signAction } from "./cadenceCode.js";

fcl.config()
  .put("accessNode.api", "https://testnet.onflow.org")
  .put("discovery.wallet", "https://flow-wallet-testnet.blocto.app/authn")
  .put("0xMS", "0x9b8f4facca188481")
  .put("0xFungibleToken", "0x9a0766d93b6608b7")
  .put("0xFlowToken", "0x7e60df042a9c0868")

const uuid = 36871535;
function App() {
  const [user, setUser] = useState({});

  useEffect(() => {
    fcl.currentUser().subscribe(setUser);
  }, []);

  const connectWallet = () => {
    if (user?.addr) {
      fcl.unauthenticate();
    } else {
      fcl.authenticate();
    }
  }

  const signActionTx = async () => {
    const intent = "Destroy Token";
    const latestBlock = await fcl.block(true);
    const intentHex = Buffer.from(`${intent}`).toString('hex');
    const MSG = `${uuid}${intentHex}${latestBlock.id}`
    console.log(intentHex);
    const sig = await fcl.currentUser().signUserMessage(MSG);
    const keyIds = sig.map((s) => {
      return s.keyId;
    });
    const signatures = sig.map((s) => {
      return s.signature;
    });
    console.log(keyIds);
    
    const transactionId = await fcl.send([
      fcl.transaction(signAction),
      fcl.args([
        fcl.arg(uuid, t.UInt64),
        fcl.arg(MSG, t.String),
        fcl.arg(keyIds, t.Array(t.Int)),
        fcl.arg(signatures, t.Array(t.String)),
        fcl.arg(latestBlock.height, t.UInt64)
      ]),
      fcl.payer(fcl.authz),
      fcl.proposer(fcl.authz),
      fcl.authorizations([fcl.authz]),
      fcl.limit(999)
    ]).then(fcl.decode);

    console.log({transactionId});
  };

  const executeActionTx = async () => {
    const transactionId = await fcl.send([
      fcl.transaction(executeAction),
      fcl.args([
        fcl.arg(uuid, t.UInt64)
      ]),
      fcl.payer(fcl.authz),
      fcl.proposer(fcl.authz),
      fcl.authorizations([fcl.authz]),
      fcl.limit(999)
    ]).then(fcl.decode);

    console.log({transactionId});
  };

  const createManagerTx = async () => {
    const transactionId = await fcl.send([
      fcl.transaction(createManager),
      fcl.args([
        fcl.arg([user.addr], t.Array(t.Address))
      ]),
      fcl.proposer(fcl.authz),
      fcl.payer(fcl.authz),
      fcl.authorizations([fcl.authz]),
      fcl.limit(999)
    ]).then(fcl.decode);

    console.log({transactionId});
  }

  const getIntentsScript = async () => {
    const result = await fcl.send([
      fcl.script(getIntents),
      fcl.args([
        fcl.arg(user.addr, t.Address)
      ])
    ]).then(fcl.decode);
    console.log(result);
  }

  return (
    <div className="App">
      <h1>User: {user?.addr}</h1>
      <div>
        <button onClick={connectWallet}>Connect Wallet</button>
      </div>
      <button onClick={createManagerTx}>Create Action</button>
      <button onClick={getIntentsScript}>Get Intents</button>
      <button onClick={signActionTx}>Sign Message</button>
      <button onClick={executeActionTx}>Execute Action</button>
    </div>
  );
}

export default App;
