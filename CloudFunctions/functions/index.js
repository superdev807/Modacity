const functions = require('firebase-functions');


// function deploy command : firebase deploy -P staging

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

function todayText() {
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1;
	var yyyy = today.getFullYear();

	if(dd<10) {
	    dd = '0'+dd
	} 

	if(mm<10) {
	    mm = '0'+mm
	} 

	return mm + '-' + dd + '-' + yyyy;
}

exports.userCreated = functions.database.ref('/users/{userId}/')
	.onCreate((snapshot, context) => {
		var today = todayText();

		admin.database().ref('/overview/stats/' + today + '/accounts')
			.transaction(count => {
		        if (count === null) {
		            return count = 1
		        } else {
		            return count + 1
		        }
		    });

		admin.database().ref('/overview/users/total')
		    .transaction(count => {
		        if (count === null) {
		            return count = 1
		        } else {
		            return count + 1
		        }
		    });

		const original = snapshot.val();
		if (original['guest'] === true) {
			admin.database().ref('/overview/stats/' + today + '/guests')
				.transaction(count => {
			        if (count === null) {
			            return count = 1
			        } else {
			            return count + 1
			        }
			    });
		}
	});

exports.userGuestLoginUpdated = functions.database.ref('/users/{userId}/profile/guest')
	.onUpdate((change, context) => {		
		const newValue = change.after.val();
      	const previousValue = change.before.val();
      	if (previousValue === true && newValue === false) {
      		var today = todayText();
      		admin.database().ref('/overview/stats/' + today + '/guests_changed')
				.transaction(count => {
			        if (count === null) {
			            return count = 1
			        } else {
			            return count + 1
			        }
			    });
      	}
	});

exports.userDeleted = functions.database.ref('/users/{userId}/')
	.onDelete((snapshot, context) => {
		admin.database().ref('/overview/users/total')
		    .transaction(count => {
		        if (count === null) {
		            return count = 0
		        } else {
		            return count - 1
		        }
		    });
	});

exports.premiumCreated = functions.database.ref('users/{userId}/premium/until')
	.onCreate((snapshot, context) => {

		admin.database().ref('/overview/users/subscribers')
		    .transaction(count => {
		        if (count === null) {
		            return count = 1
		        } else {
		            return count + 1
		        }
		    });

		var today = todayText();

		admin.database().ref('/overview/stats/' + today + '/subscribers')
			.transaction(count => {
		        if (count === null) {
		            return count = 1
		        } else {
		            return count + 1
		        }
		    });
		
	});

exports.premiumDeleted = functions.database.ref('users/{userId}/premium/until')
	.onDelete((snapshot, context) => {
		admin.database().ref('/overview/users/subscribers')
			.transaction(count => {
				if (count === null) {
					return count = 0
				} else {
					return count - 1
				}
			});
	});