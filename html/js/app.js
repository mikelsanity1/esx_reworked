(() => {

	ESR = {};
	ESR.HUDElements = [];

	ESR.setHUDDisplay = function (opacity) {
		$('#hud').css('opacity', opacity);
	};

	ESR.insertHUDElement = function (name, index, priority, html, data) {
		ESR.HUDElements.push({
			name: name,
			index: index,
			priority: priority,
			html: html,
			data: data
		});

		ESR.HUDElements.sort((a, b) => {
			return a.index - b.index || b.priority - a.priority;
		});
	};

	ESR.updateHUDElement = function (name, data) {
		for (let i = 0; i < ESR.HUDElements.length; i++) {
			if (ESR.HUDElements[i].name == name) {
				ESR.HUDElements[i].data = data;
			}
		}

		ESR.refreshHUD();
	};

	ESR.deleteHUDElement = function (name) {
		for (let i = 0; i < ESR.HUDElements.length; i++) {
			if (ESR.HUDElements[i].name == name) {
				ESR.HUDElements.splice(i, 1);
			}
		}

		ESR.refreshHUD();
	};

	ESR.refreshHUD = function () {
		$('#hud').html('');

		for (let i = 0; i < ESR.HUDElements.length; i++) {
			let html = Mustache.render(ESR.HUDElements[i].html, ESR.HUDElements[i].data);
			$('#hud').append(html);
		}
	};

	ESR.inventoryNotification = function (add, label, count) {
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
				ESR.setHUDDisplay(data.opacity);
				break;
			}

			case 'insertHUDElement': {
				ESR.insertHUDElement(data.name, data.index, data.priority, data.html, data.data);
				break;
			}

			case 'updateHUDElement': {
				ESR.updateHUDElement(data.name, data.data);
				break;
			}

			case 'deleteHUDElement': {
				ESR.deleteHUDElement(data.name);
				break;
			}

			case 'inventoryNotification': {
				ESR.inventoryNotification(data.add, data.item, data.count);
			}
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();
