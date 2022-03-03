import DAOTreasury from "../DAOTreasury.cdc"

transaction(initialSigners: [Address]) {
  
  prepare(signer: AuthAccount) {
    signer.save(<- DAOTreasury.createTreasury(initialSigners: initialSigners), to: DAOTreasury.TreasuryStoragePath)
    signer.link<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>(DAOTreasury.TreasuryPublicPath, target: DAOTreasury.TreasuryStoragePath)
  }
  execute {
    
  }
}