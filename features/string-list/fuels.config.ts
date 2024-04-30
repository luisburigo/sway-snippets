import { createConfig } from 'fuels';

export default createConfig({
  contracts: [
    "./sway/string-list",
  ],
  autoStartFuelCore: false,
  providerUrl: 'http://localhost:4000/graphql',
  privateKey: '0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298',
  output: './types',
});
