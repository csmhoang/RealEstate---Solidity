const express = require("express");
const app = express();

// Endpoint trả về JSON metadata NFT
app.get("/nft/1", (req, res) => {
  res.json({
    name: "Luxury NYC Penthouse",
    address: "157 W 57th St APT 49B, New York, NY 10019",
    description: "Luxury Penthouse located in the heart of NYC",
    image:
      "https://ipfs.io/ipfs/QmQUozrHLAusXDxrvsESJ3PYB3rUeUuBAvVWw6nop2uu7c/1.png",
    id: "1",
    attributes: [
      { trait_type: "Purchase Price", value: 20 },
      { trait_type: "Type of Residence", value: "Condo" },
      { trait_type: "Bed Rooms", value: 2 },
      { trait_type: "Bathrooms", value: 3 },
      { trait_type: "Square Feet", value: 2200 },
      { trait_type: "Year Built", value: 2013 },
    ],
  });
});

// Chạy server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () =>
  console.log(`Server is running on http://localhost:${PORT}`)
);
