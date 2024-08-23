const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const upgradeModule = buildModule("UpgradeModule", (m) => {
  const proxyAdminOwner = m.getAccount(0);

  const { proxyAdmin, proxy } = m.useModule(require("./ProxyModule"));

  const upgrade2 = m.contract("Upgrade2");

  m.call(proxyAdmin, "upgrade", [proxy, upgrade2], {
    from: proxyAdminOwner,
  });

  return { proxyAdmin, proxy };
});

module.exports = upgradeModule;
