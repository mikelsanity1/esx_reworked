(() => {

	ESXR = {};
	ESXR.HUDElements = [];

	ESXR.setHUDDisplay = function (opacity) {
		$('#hud').css('opacity', opacity);
	};

	ESXR.insertHUDElement = function (name, index, priority, html, data) {
		ESXR.HUDElements.push({
			name: name,
			index: index,
			priority: priority,
			html: html,
			data: data
		});

		ESXR.HUDElements.sort((a, b) => {
			return a.index - b.index || b.priority - a.priority;
		});
	};

	ESXR.updateHUDElement = function (name, data) {
		for (let i = 0; i < ESXR.HUDElements.length; i++) {
			if (ESXR.HUDElements[i].name == name) {
				ESXR.HUDElements[i].data = data;
			}
		}

		ESXR.refreshHUD();
	};

	ESXR.deleteHUDElement = function (name) {
		for (let i = 0; i < ESXR.HUDElements.length; i++) {
			if (ESXR.HUDElements[i].name == name) {
				ESXR.HUDElements.splice(i, 1);
			}
		}

		ESXR.refreshHUD();
	};

	ESXR.refreshHUD = function () {
		$('#hud').html('');

		for (let i = 0; i < ESXR.HUDElements.length; i++) {
			let html = Mustache.render(ESXR.HUDElements[i].html, ESXR.HUDElements[i].data);
			$('#hud').append(html);
		}
	};

	ESXR.inventoryNotification = function (add, label, count) {
		let notif = '';

		if (add) {
			notif += '+';
		} else {
			notif += '-';
		}

		if (count) {
			notif += count + ' ' + label;
		} else {
			notif += ' ' + label;
		}

		let elem = $('<div>' + notif + '</div>');
		$('#inventory_notifications').append(elem);

		$(elem).delay(3000).fadeOut(1000, function () {
			elem.remove();
		});
	};

	window.onData = (data) => {
		switch (data.action) {
			case 'setHUDDisplay': {
				ESXR.setHUDDisplay(data.opacity);
				break;
			}

			case 'insertHUDElement': {
				ESXR.insertHUDElement(data.name, data.index, data.priority, data.html, data.data);
				break;
			}

			case 'updateHUDElement': {
				ESXR.updateHUDElement(data.name, data.data);
				break;
			}

			case 'deleteHUDElement': {
				ESXR.deleteHUDElement(data.name);
				break;
			}

			case 'inventoryNotification': {
				ESXR.inventoryNotification(data.add, data.item, data.count);
			}
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();
