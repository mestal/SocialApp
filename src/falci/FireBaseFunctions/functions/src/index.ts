import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

    enum FalStatus{
        Draft,
        SentByUser,
        CommentedByFT,
        CommentSeenByUser
    }

    admin.initializeApp(functions.config().firebase);
    console.log('function started 111');

    // exports.onWrite1 = functions.firestore.document('Fal').onWrite((event, context) => {
    //     console.log('onWrite started123');
    // });

    exports.onCreate = functions.firestore
    .document('Fal/{id}')
    .onCreate((snap, context) => {
        console.log('onCreate started');
        
        const newValue = snap.data();
        console.log(newValue);

        var falciId = "";
        if(newValue != null && newValue.FortuneTellerUserId != null)
        {
            falciId = newValue.FortuneTellerUserId;
            console.log('FortuneTellerUserId: ' + falciId);
        }
        else{
            console.log('FortuneTellerUserId: not reached');
            return;
        }
        const ref1 = admin.firestore().doc(`User/${falciId}`);
        
        return ref1.get().then(function(snapshot){
            
            const falci = snapshot.data();
            if(falci == null) {
                console.log('Falcı: not reached');
                return;
            }

            console.log('Falcı Name: ' + falci.Name);
            console.log('Falcı Messaging Token: ' + falci.MessagingToken);
                
            if(falci.MessagingToken == null || falci.MessagingToken == "")
            {
                return;
            }
            const payload = {
                notification: {
                    title: 'Yeni fal geldi.',
                    body: 'Üye: ' + newValue.UserName
                }
            };

            admin.messaging().sendToDevice(falci.MessagingToken, payload).then(function(response) {
                console.log('Falcıya yeni fal bilgisi gönderildi.');
            }).catch(function(error)
            {
                console.log('Falcıya yeni fal bilgisi gönderilemedi. Error: ' + error);
            });

        }).catch(function(error)
        {
            console.log('${falciId} userının (falcı) tokenına ulaşılamadı.');
        });
    });

    exports.onUpdate = functions.firestore.document('Fal/{falId}').onUpdate((event, context) => {
        const oldData = event.before.data();
        const newData = event.after.data();
        console.log('onUpdate started');
        if(oldData == null)
        {
            console.log('onUpdate oldData == null');
            return;
        }
            
        if(newData == null)
        {
            console.log('onUpdate newData == null');
            return;
        }

        if(oldData.Status == FalStatus.SentByUser && newData.Status == FalStatus.CommentedByFT)
        {
            const userId = newData.UserId;
            const ref2 = admin.firestore().doc(`User/${userId}`);
        
            return ref2.get().then(function(snapshot){
            
                const user = snapshot.data();
                if(user == null) {
                    console.log('User: not reached');
                    return;
                }
    
                console.log('User Name: ' + user.Name);
                console.log('User Messaging Token: ' + user.MessagingToken);
                    
                if(user.MessagingToken == null || user.MessagingToken == "")
                {
                    return;
                }
                const payload = {
                    notification: {
                        title: 'Falnıza bakıldı',
                        body: 'Fal yorumunuzu okuyabilirsiniz.'
                    }
                };
    
                admin.messaging().sendToDevice(user.MessagingToken, payload).then(function(response) {
                    console.log('Üyeye fal bakıldı bilgisi gönderildi. Üye: ' + newData.UserName);
                }).catch(function(error)
                {
                    console.log('Üyeye fal bakıldı bilgisi gönderilemedi. Error: ' + error);
                });
    
            }).catch(function(error)
            {
                console.log('${userId} userının (üye) tokenına ulaşılamadı.');
            });
        }
        return true;
    });

// export const helloWorld = functions.https.onRequest((request, response) => {
//     console.log('deneme1234');
//  response.send("Hello from Falci!");


// });
