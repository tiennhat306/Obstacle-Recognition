/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");

const {getAddressFromLatLng} = require("./ggmapService");

var admin = require("firebase-admin");

var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://visionaid-dut210-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const express = require("express");
const cors = require("cors");

// Main App
const app = express();
app.use(cors({ origin: true }));

const db = admin.firestore();

// Routes
app.get("/", (req, res) => {
  return res.status(200).send("Hello World");
});

app.put("/api/update-location/:device_key", (req, res) => {
    (async () => {
        try {
            const snapshot = await db.collection("devices").where("key", "==", req.params.device_key).limit(1).get();
            if (!snapshot.empty) {
                const doc = snapshot.docs[0];
                const newLocation = {
                    latitude: req.body.latitude,
                    longitude: req.body.longitude,
                    datetime: new Date().toISOString()
                };
                await db.collection("devices").doc(doc.id).update({
                    location: newLocation,
                    history: admin.firestore.FieldValue.arrayUnion(newLocation)
                });
                return res.status(200).send({msg: "Device's location updated successfully"});
            } else {
                return res.status(404).send({msg: "Device not found"});
            }
        } catch (error) {
            return res.status(500).send({msg: "Error updating device's location", error: getAddressFromLatLng(req.body.latitude, req.body.longitude)});
        }   
    })();
});


exports.app = functions.https.onRequest(app);


