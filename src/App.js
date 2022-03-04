import './App.css';
import {useEffect, useState} from 'react';
import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";
import { createTreasury, executeAction, getIntents, getIntent, signAction, proposeAction, fundTreasury, getVaultBalance, getTreasuryIdentifiers } from "./cadenceCode.js";

fcl.config()
  .put("accessNode.api", "https://testnet.onflow.org")
  .put("discovery.wallet", "https://flow-wallet-testnet.blocto.app/authn")
  .put("0xMS", "0x9b8f4facca188481")
  .put("0xFungibleToken", "0x9a0766d93b6608b7")
  .put("0xFlowToken", "0x7e60df042a9c0868")

const treasury = '0x6c0d53c676256e8c';
function App() {
  const [user, setUser] = useState({});
  const [actionUUID, setActionUUID] = useState();
  const [recipientAddr, setRecipientAddr] = useState();
  const [amount, setAmount] = useState();

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

  const createTreasuryTx = async () => {
    const transactionId = await fcl.send([
      fcl.transaction(createTreasury),
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

  const fundTreasuryTx = async () => {
    const transactionId = await fcl.send([
      fcl.transaction(fundTreasury),
      fcl.args([
        fcl.arg(treasury, t.Address),
        fcl.arg("10.0", t.UFix64)
      ]),
      fcl.proposer(fcl.authz),
      fcl.payer(fcl.authz),
      fcl.authorizations([fcl.authz]),
      fcl.limit(999)
    ]).then(fcl.decode);

    console.log({transactionId});
  }

  const getTreasuryIdentifiersScript = async () => {
    const result = await fcl.send([
      fcl.script(getTreasuryIdentifiers),
      fcl.args([
        fcl.arg(treasury, t.Address)
      ])
    ]).then(fcl.decode);
    console.log(result);
  }

  const getVaultBalanceScript = async () => {
    const result = await fcl.send([
      fcl.script(getVaultBalance),
      fcl.args([
        fcl.arg(treasury, t.Address)
      ])
    ]).then(fcl.decode);
    console.log(result);
  }

  const getIntentScript = async () => {
    const result = await fcl.send([
      fcl.script(getIntent),
      fcl.args([
        fcl.arg(treasury, t.Address),
        fcl.arg(parseInt(actionUUID), t.UInt64)
      ])
    ]).then(fcl.decode);
    console.log(result);
    return result;
  }

  const proposeActionTx = async () => {
    const transactionId = await fcl.send([
      fcl.transaction(proposeAction),
      fcl.args([
        fcl.arg(treasury, t.Address),
        fcl.arg(recipientAddr, t.Address),
        fcl.arg(amount, t.UFix64)
      ]),
      fcl.payer(fcl.authz),
      fcl.proposer(fcl.authz),
      fcl.authorizations([fcl.authz]),
      fcl.limit(999)
    ]).then(fcl.decode);

    console.log({transactionId});
  }

  const signActionTx = async () => {
    const intent = await getIntentScript(actionUUID);
    const latestBlock = await fcl.block(true);
    const intentHex = Buffer.from(`${intent}`).toString('hex');
    const MSG = `${actionUUID}${intentHex}${latestBlock.id}`
    console.log(intentHex);
    const sig = await fcl.currentUser().signUserMessage(MSG);
    const keyIds = sig.map((s) => {
      return s.keyId;
    });
    const signatures = sig.map((s) => {
      return s.signature;
    });
    
    const transactionId = await fcl.send([
      fcl.transaction(signAction),
      fcl.args([
        fcl.arg(treasury, t.Address),
        fcl.arg(parseInt(actionUUID), t.UInt64),
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
        fcl.arg(treasury, t.Address),
        fcl.arg(parseInt(actionUUID), t.UInt64)
      ]),
      fcl.payer(fcl.authz),
      fcl.proposer(fcl.authz),
      fcl.authorizations([fcl.authz]),
      fcl.limit(999)
    ]).then(fcl.decode);

    console.log({transactionId});
  };

  const getIntentsScript = async () => {
    const result = await fcl.send([
      fcl.script(getIntents),
      fcl.args([
        fcl.arg(treasury, t.Address)
      ])
    ]).then(fcl.decode);
    console.log(result);
  }

  return (
    <div className="App">
      <div>
        <h1>User: {user?.addr}</h1>
        <button onClick={connectWallet}>Connect Wallet</button>
      </div>

      <div>
        <p>Action UUID:</p>
        <input type="text" onChange={e => setActionUUID(e.target.value)} />
      </div>

      <button onClick={createTreasuryTx}>Create Treasury</button>
      <button onClick={fundTreasuryTx}>Fund Treasury</button>
      <button onClick={getTreasuryIdentifiersScript}>Get Identifiers</button>
      <button onClick={getVaultBalanceScript}>Get Treasury Balance</button>
      <button onClick={proposeActionTx}>Propose Action</button>

      <div>
        <p>Recipient Address:</p>
        <input type="text" onChange={e => setRecipientAddr(e.target.value)} />
        <p>Amount:</p>
        <input type="text" onChange={e => setAmount(e.target.value)} />
      </div>

      <button onClick={getIntentsScript}>Get Intents</button>
      <button onClick={signActionTx}>Sign Message</button>
      <button onClick={executeActionTx}>Execute Action</button>
    </div>
  );
}

export default App;
