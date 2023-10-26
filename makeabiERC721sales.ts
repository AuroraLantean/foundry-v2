const lg = console.log;
lg("makeAbi.ts is running...")
import erc20dp6 from "./out/ERC20Token.sol/ERC20DP6.json"
  ;
import erc721token from "./out/ERC721Token.sol/ERC721Token.json"
import erc721sales from "./out/ERC721Sales.sol/ERC721Sales.json"
import localdeployment from "./broadcast/LocalDeploymt.s.sol/31337/run-latest.json"
const remotedeployment = null;

const abiDestination = process.env.ABI_DESTINATION || './out_abis/contractABIsX.json'
lg("ABI_DESTINATION:", abiDestination)
//import remotedeployment from "./broadcast/RemoteDeploymt.s.sol/31337/run-latest.json"
//lg("erc20dp6", erc20dp6.abi)
//lg("erc721token", erc721token.abi)
//lg("erc721sales", erc721sales.abi)

//lg("localdeployment", localdeployment.transactions)
const isLocal = 1 === 1;
const deployment = isLocal ? localdeployment : remotedeployment;

const out = deployment?.transactions.map(box => {
  if (box.transactionType === "CREATE") {
    //lg(box.contractName, box.contractAddress)
    return {
      contractName: box.contractName,
      contractAddress: box.contractAddress
    }
  }
})
//lg("out:", out)

const out2 = out?.map(box => {
  if (box?.contractName === "ERC20DP6") return {
    ...box, abi: erc20dp6.abi
  }
  if (box?.contractName === "ERC721Token") return {
    ...box, abi: erc721token.abi
  }
  if (box?.contractName === "ERC721Sales") return {
    ...box, abi: erc721sales.abi
  }
})
//lg("out2:", out2, out2.length)
const out3 = out2?.filter(box => box !== undefined)
//lg("out3:", out3)
lg("out3:", out3?.length)
await Bun.write("./out_abis/contractABIsERC721Sales.json", JSON.stringify(out3));

const input = Bun.file("./out_abis/contractABIsERC721Sales.json");
const output = Bun.file(abiDestination); // doesn't exist yet!
await Bun.write(output, input);
