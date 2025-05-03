const MAX_NOTIFICATIONS = 5;

let config = {
    defaultPosition: 'top-right',
    currentPosition: 'top-right',
    notificationStyles: {
        BackgroundColor: 'rgba(20, 20, 40, 0.85)',
        TextColor: '#ffffff',
        BorderWidth: '5px',
        BorderRadius: '8px',
        FontSize: '15px',
        Width: '350px',
        Padding: '15px',
        MarginBottom: '12px',
        Duration: 5000
    },
    notificationTypes: {
        'success': {
            icon: '<i class="fas fa-check-circle"></i>',
            borderColor: '#2ecc71',
            backgroundColor: 'rgba(20, 40, 20, 0.85)'
        },
        'error': {
            icon: '<i class="fas fa-times-circle"></i>',
            borderColor: '#e74c3c',
            backgroundColor: 'rgba(40, 20, 20, 0.85)'
        },
        'info': {
            icon: '<i class="fas fa-info-circle"></i>',
            borderColor: '#3498db',
            backgroundColor: 'rgba(20, 20, 40, 0.85)'
        },
        'warning': {
            icon: '<i class="fas fa-exclamation-triangle"></i>',
            borderColor: '#f39c12',
            backgroundColor: 'rgba(40, 35, 10, 0.85)'
        }
    }
};

function generateId() {
    return 'notification-' + Math.random().toString(36).substr(2, 9);
}

function formatMessage(message) {
    message = message.replace(/~r~/g, '<span style="color: #e74c3c;">');
    message = message.replace(/~g~/g, '<span style="color: #2ecc71;">');
    message = message.replace(/~b~/g, '<span style="color: #3498db;">');
    message = message.replace(/~y~/g, '<span style="color: #f39c12;">');
    message = message.replace(/~w~/g, '<span style="color: #ffffff;">');
    message = message.replace(/~s~/g, '</span>');
    
    const urlRegex = /(https?:\/\/[^\s]+)/g;
    message = message.replace(urlRegex, '<a href="$1" target="_blank">$1</a>');
    
    return message;
}

function showNotification(data) {
    const position = data.position || config.currentPosition;
    const container = document.getElementById(position);
    
    if (!container) return;
    
    const existingNotifications = container.querySelectorAll('.notification');
    if (existingNotifications.length >= MAX_NOTIFICATIONS) {
        const oldestNotification = existingNotifications[0];
        if (oldestNotification) {
            oldestNotification.classList.add('hiding');
            setTimeout(() => {
                if (oldestNotification.parentNode) {
                    oldestNotification.parentNode.removeChild(oldestNotification);
                }
            }, 300);
        }
    }
    
    const type = data.type && config.notificationTypes[data.type] 
        ? data.type 
        : 'info';
    
    const notificationType = config.notificationTypes[type];
    
    const id = generateId();
    const notification = document.createElement('div');
    notification.id = id;
    notification.className = 'notification';
    notification.style.backgroundColor = notificationType.backgroundColor;
    notification.style.color = config.notificationStyles.TextColor;
    notification.style.borderLeft = `${config.notificationStyles.BorderWidth} solid ${notificationType.borderColor}`;
    notification.style.borderRadius = config.notificationStyles.BorderRadius;
    
    const iconDiv = document.createElement('div');
    iconDiv.className = 'notification-icon';
    iconDiv.innerHTML = notificationType.icon;
    iconDiv.style.color = notificationType.borderColor;
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'notification-content';
    contentDiv.innerHTML = formatMessage(data.message);
    
    const progressBar = document.createElement('div');
    progressBar.className = 'notification-progress';
    progressBar.style.backgroundColor = notificationType.borderColor;
    
    notification.appendChild(iconDiv);
    notification.appendChild(contentDiv);
    notification.appendChild(progressBar);
    
    if (container.firstChild) {
        container.insertBefore(notification, container.firstChild);
    } else {
        container.appendChild(notification);
    }
    
    const duration = data.duration || config.notificationStyles.Duration;
    progressBar.style.transition = `width ${duration}ms linear`;
    
    setTimeout(() => {
        progressBar.style.width = '0';
    }, 10);
    
    setTimeout(() => {
        notification.classList.add('hiding');
        
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, duration);
    
    return id;
}

function changePosition(position) {
    if (position) {
        config.currentPosition = position;
    }
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'showNotification') {
        showNotification(data.data);
    } else if (data.action === 'changePosition') {
        changePosition(data.position);
    } else if (data.action === 'updateConfig') {
        if (data.config) {
            if (data.config.defaultPosition) 
                config.defaultPosition = data.config.defaultPosition;
            
            if (data.config.notificationStyles) 
                config.notificationStyles = data.config.notificationStyles;
            
            if (data.config.notificationTypes) 
                config.notificationTypes = data.config.notificationTypes;
        }
    } else if (data.action === 'initialize') {
        document.documentElement.style.backgroundColor = 'transparent';
        document.body.style.backgroundColor = 'transparent';
    }
});

window.onload = function() {
    document.documentElement.style.backgroundColor = 'transparent';
    document.body.style.backgroundColor = 'transparent';
    
    fetch(`https://${GetParentResourceName()}/nuiReady`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).catch(() => {
    });
};
