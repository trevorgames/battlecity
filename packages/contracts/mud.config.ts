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
      }
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
      }
    }
  },
});
