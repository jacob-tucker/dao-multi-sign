import MyMultiSig from "../MyMultiSig.cdc"

pub fun main(account: Address): {UInt64: String} {
  let managerPublic = getAccount(account).getCapability(/public/Manager001)
                        .borrow<&MyMultiSig.Manager{MyMultiSig.ManagerPublic}>()
                        ?? panic("This account doesn't have a manager")
  return managerPublic.getIntents()
}