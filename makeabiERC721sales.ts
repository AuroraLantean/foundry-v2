const lg = console.log;
lg("makeAbi.ts is running...")
import erc20dp6JSON from "./out/ERC20Token.sol/ERC20DP6.json"
  ;
import erc721tokenJSON from "./out/ERC721Token.sol/ERC721Token.json"
import erc721salesJSON from "./out/ERC721Sales.sol/ERC721Sales.json"
import arrayOfStructsJSON from "./out/ERC721Sales.sol/ArrayOfStructs.json"

import localdeployment from "./broadcast/LocalDeploymt.s.sol/31337/run-latest.json"
const remotedeployment = null;

const abiDestination = process.env.ABI_DESTINATION || './out_abis/contractABIsX.json'
lg("ABI_DESTINATION:", abiDestination)
//import remotedeployment from "./broadcast/RemoteDeploymt.s.sol/31337/run-latest.json"
//lg("erc20dp6JSON", erc20dp6JSON.abi)
//lg("erc721tokenJSON", erc721tokenJSON.abi)
//lg("erc721salesJSON", erc721salesJSON.abi)

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
let erc20dp6Addr = '';
let erc721Addr = '';
let erc721salesAddr = '';
let arrayOfStructsAddr = '';

const out2 = out?.map(box => {
  if (box?.contractName === "ERC20DP6") {
    erc20dp6Addr = box.contractAddress;
    return {
      ...box, abi: erc20dp6JSON.abi
    }
  }
  if (box?.contractName === "ERC721Token") {
    erc721Addr = box.contractAddress;
    return {
      ...box, abi: erc721tokenJSON.abi
    }
  }
  if (box?.contractName === "ERC721Sales") {
    erc721salesAddr = box.contractAddress;
    return {
      ...box, abi: erc721salesJSON.abi
    }
  }
  if (box?.contractName === "ArrayOfStructs") {
    arrayOfStructsAddr = box.contractAddress;
    return {
      ...box, abi: arrayOfStructsJSON.abi
    }
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
lg('erc20dp6Addr:', erc20dp6Addr)
lg('erc721Addr:', erc721Addr)
lg('erc721salesAddr:', erc721salesAddr)
lg('arrayOfStructsAddr:', arrayOfStructsAddr)
