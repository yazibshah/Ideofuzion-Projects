const demoModule = buildModule("DemoModule", (m) => {
    const { proxy, proxyAdmin } = m.useModule(proxyModule);
  
    const demo = m.contractAt("Upgrade", proxy);

    const encodedFunctionCall = m.encodeFunctionCall(demo, "add", [1,2]);
  
    return { demo, proxy, proxyAdmin };
  });