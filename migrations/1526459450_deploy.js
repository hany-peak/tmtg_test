
//계약 정보 읽어오기
const DNextToken = artifacts.require("./DNextToken");
const DNextTokenSale = artifacts.require("./DNextTokenSale");
const DNextTokenWhitelist = artifacts.require("./DNextTOkenWhitelist");

module.exports = function(deployer) {
  //truffle이 제공해주는 배포 툴
  deployer.deploy(DNextToken).then(function(){
    deployer.deploy(DNextTokenWhitelist).then(function(){
      deployer.deploy(DNextTokenSale, DNextToken.address, 
        DNextTokenSale.address);
    });
  });
};
