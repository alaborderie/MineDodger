import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
const cors = require('cors')({origin: true});
import {DocumentSnapshot} from "firebase-functions/lib/providers/firestore";

admin.initializeApp(functions.config().firebase);

export const username = functions.https.onRequest(async (request, response) => {
    cors(request, response, async () => {
        const username: string = request.query.username;
        const user: DocumentSnapshot = await admin.firestore().doc('users/' + username).get();
        if (user.exists) {
            response.status(200).json(user.data());
        } else {
            const newUser = {username, maxLevel: 0};
            await admin.firestore().doc('users/' + username).set(newUser);
            response.status(201).json(newUser);
        }
    });
});

export const updateMaxLevel = functions.https.onRequest(async (request, response) => {
    cors(request, response, async () => {
        const username: string = request.query.username;
        const maxLevel: number = Number(request.query.maxLevel);
        const user: DocumentSnapshot = await admin.firestore().doc('users/' + username).get();
        if (user.exists) {
            if ((user.data() || {}).maxLevel < maxLevel) {
                const updatedUser = user.data() || {username, maxLevel};
                updatedUser.maxLevel = maxLevel;
                await admin.firestore().doc('users/' + username).set(updatedUser);
                response.status(200).json(updatedUser);
            } else {
                response.status(200).json(user.data());
            }
        } else {
            response.status(404).json({error: "User not found with username = " + username});
        }
    });
});