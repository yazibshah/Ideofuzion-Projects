const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const proxyModule = buildModule("ProxyModule", (m) => {
  const proxyAdminOwner = m.getAccount(0);

  const upgrade = m.contract("Upgrade");

  const proxy = m.contract("TransparentUpgradeableProxy", [
    upgrade,
    proxyAdminOwner,
    "0x",
  ]);

  const proxyAdminAddress = m.readEventArgument(
    proxy,
    "AdminChanged",
    "newAdmin"
  );

  const proxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

  return { proxyAdmin, proxy };
});

module.exports = proxyModule;
