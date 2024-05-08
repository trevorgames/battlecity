import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  tables: {
    Counter: {
      schema: {
        value: "uint32",
      },
      key: [],
    },

    Config: {
      key: [],
      schema: {
        locked: "bool",
        swordToken: "address",
        seasonPassToken: "address",
        strategoKeyToken: "address",
      },
    },

    /**
     * Marks an address entity as an admin.
     */
    Admin: "bool",

    Name: "string",
    NameExists: {
      key: ["nameData"],
      schema: {
        nameData: "bytes32",
        value: "bool",
      },
    },

    Verifier: {
      key: [],
      schema: {
        setupVerifier: "address",
        moveVerifier: "address",
        attackVerifier: "address",
        defenseVerifier: "address",
      },
    },

    MatchConfig: {
      key: ["matchEntity"],
      schema: {
        matchEntity: "bytes32",
        registrationTime: "uint256", // timestamp in seconds since the epoch
        startTime: "uint256", // timestamp in seconds since the epoch
        turnLength: "uint256", // seconds
        createdBy: "bytes32",
      },
    },

    SeasonPassIndex: {
      key: [],
      schema: {
        tokenIndex: "uint256", // incrementing token ID of season passes
      },
    },
    SeasonPassConfig: {
      key: [],
      schema: {
        minPrice: "uint256", // minimum price
        startingPrice: "uint256", // starting price
        rate: "uint256", // price decrease per second
        multiplier: "uint256", // price increase multiplier per purchase
        mintCutoff: "uint256", // mint cutoff time
      },
    },
    SeasonTimes: {
      key: [],
      schema: {
        seasonStart: "uint256",
        seasonEnd: "uint256",
      },
    },
    SeasonPassSale: {
      type: "offchainTable",
      key: ["buyer", "tokenId"],
      schema: {
        buyer: "address",
        tokenId: "uint256",
        price: "uint256",
        purchasedAt: "uint256",
        tokenAddress: "address",
      },
    },
    SeasonPassLastSaleAt: {
      key: [],
      schema: {
        lastSaleAt: "uint256",
      },
    },
  },
});
