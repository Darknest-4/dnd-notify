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

let activeNotifications = new Set();

function formatMessage(message) {
    if (!message) return '';
    
    if (typeof message !== 'string') {
        console.error('Invalid message type received');
        return '';
    }
    
    function escapeHtml(unsafe) {
        return unsafe
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }
    
    message = escapeHtml(message);
    
    message = message.replace(/~r~/g, '<span style="color: #e74c3c;">');
    message = message.replace(/~g~/g, '<span style="color: #2ecc71;">');
    message = message.replace(/~b~/g, '<span style="color: #3498db;">');
    message = message.replace(/~y~/g, '<span style="color: #f39c12;">');
    message = message.replace(/~w~/g, '<span style="color: #ffffff;">');
    message = message.replace(/~s~/g, '</span>');
    
    const urlRegex = /(https?:\/\/[^\s]+)/g;
    message = message.replace(urlRegex, function(match) {
        if (match.startsWith('http://') || match.startsWith('https://')) {
            const sanitizedUrl = match.replace(/[\(\)\[\]<>"']/g, '');
            return '<a href="' + sanitizedUrl + '" target="_blank" rel="noopener noreferrer">' + sanitizedUrl + '</a>';
        }
        return match;
    });
    
    message = message.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    message = message.replace(/\*(.*?)\*/g, '<em>$1</em>');
    message = message.replace(/~~(.*?)~~/g, '<del>$1</del>');
    message = message.replace(/`(.*?)`/g, '<code>$1</code>');
    
    return message;
}

function showNotification(data) {
    const position = data.position || config.currentPosition;
    const container = document.getElementById(position);
    
    if (!container) return;
    
    if (data.id && activeNotifications.has(data.id)) {
        return data.id;
    }
    
    const existingNotifications = container.querySelectorAll('.notification');
    if (existingNotifications.length >= MAX_NOTIFICATIONS) {
        const oldestNotification = existingNotifications[0];
        if (oldestNotification) {
            oldestNotification.classList.add('hiding');
            setTimeout(() => {
                if (oldestNotification.parentNode) {
                    oldestNotification.parentNode.removeChild(oldestNotification);
                    const notificationId = oldestNotification.getAttribute('data-unique-id');
                    if (notificationId) activeNotifications.delete(notificationId);
                }
            }, 300);
        }
    }
    
    const type = data.type && config.notificationTypes[data.type] 
        ? data.type 
        : 'info';
    
    const notificationType = config.notificationTypes[type];
    
    const id = data.id || generateId();
    if (data.id) activeNotifications.add(data.id);
    
    const notification = document.createElement('div');
    notification.id = id;
    notification.className = 'notification';
    notification.setAttribute('data-unique-id', data.id || '');
    notification.style.backgroundColor = notificationType.backgroundColor;
    notification.style.color = config.notificationStyles.TextColor;
    notification.style.borderLeft = `${config.notificationStyles.BorderWidth} solid ${notificationType.borderColor}`;
    notification.style.borderRadius = config.notificationStyles.BorderRadius;
    notification.style.width = config.notificationStyles.Width;
    notification.style.minWidth = config.notificationStyles.MinWidth || '300px';
    notification.style.minHeight = config.notificationStyles.MinHeight || '80px';
    
    const iconDiv = document.createElement('div');
    iconDiv.className = 'notification-icon';
    iconDiv.innerHTML = data.icon || notificationType.icon;
    iconDiv.style.color = data.iconColor || notificationType.borderColor;
    
    if (data.iconAnimation) {
        iconDiv.classList.add(`fa-${data.iconAnimation}`);
    }
    
    if (data.alignIcon) {
        iconDiv.style.alignSelf = data.alignIcon === 'top' ? 'flex-start' : 'center';
    }
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'notification-content';
    
    if (data.title) {
        const titleDiv = document.createElement('div');
        titleDiv.className = 'notification-title';
        titleDiv.innerHTML = formatMessage(data.title);
        contentDiv.appendChild(titleDiv);
    }
    
    const messageDiv = document.createElement('div');
    messageDiv.className = 'notification-message';
    messageDiv.innerHTML = formatMessage(data.description || data.message);
    contentDiv.appendChild(messageDiv);
    
    const progressBar = document.createElement('div');
    progressBar.className = 'notification-progress';
    progressBar.style.backgroundColor = notificationType.borderColor;
    
    if (data.showDuration === false) {
        progressBar.style.display = 'none';
    }
    
    if (data.style) {
        for (const [key, value] of Object.entries(data.style)) {
            notification.style[key] = value;
        }
    }
    
    notification.appendChild(iconDiv);
    notification.appendChild(contentDiv);
    notification.appendChild(progressBar);
    
    if (container.firstChild) {
        container.insertBefore(notification, container.firstChild);
    } else {
        container.appendChild(notification);
    }
    
    if (data.sound) {
        if (data.sound.name) {
            const soundSet = data.sound.set || '';
            const soundBank = data.sound.bank || '';
            SendNUIMessage({
                action: 'playSound',
                name: data.sound.name,
                set: soundSet,
                bank: soundBank
            });
        }
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
                if (data.id) activeNotifications.delete(data.id);
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
    try {
        if (!event.data || typeof event.data !== 'object') {
            return;
        }
        
        const data = event.data;
        
        const allowedActions = ['showNotification', 'changePosition', 'updateConfig', 'initialize', 'playSound'];
        if (!data.action || !allowedActions.includes(data.action)) {
            console.error('Invalid action received:', data.action);
            return;
        }
        
        if (data.action === 'showNotification') {
            if (data.data && typeof data.data === 'object') {
                showNotification(data.data);
            }
        } else if (data.action === 'changePosition') {
            // Validate position
            const validPositions = [
                'top-left', 'top-center', 'top-right',
                'middle-left', 'middle-center', 'middle-right',
                'bottom-left', 'bottom-center', 'bottom-right'
            ];
            
            if (data.position && validPositions.includes(data.position)) {
                changePosition(data.position);
            }
        } else if (data.action === 'updateConfig') {
            if (data.config && typeof data.config === 'object') {
                if (data.config.defaultPosition && typeof data.config.defaultPosition === 'string') {
                    const validPositions = [
                        'top-left', 'top-center', 'top-right',
                        'middle-left', 'middle-center', 'middle-right',
                        'bottom-left', 'bottom-center', 'bottom-right'
                    ];
                    
                    if (validPositions.includes(data.config.defaultPosition)) {
                        config.defaultPosition = data.config.defaultPosition;
                        config.currentPosition = data.config.defaultPosition;
                    }
                }
                
                if (data.config.notificationStyles && typeof data.config.notificationStyles === 'object') {
                    const safeStyles = {};
                    const allowedStyleProps = ['BackgroundColor', 'TextColor', 'BorderWidth', 'BorderRadius',
                                           'FontSize', 'Width', 'MinWidth', 'MinHeight', 'Padding', 
                                           'MarginBottom', 'Duration'];
                    
                    for (const prop of allowedStyleProps) {
                        if (data.config.notificationStyles[prop] !== undefined) {
                            if (prop === 'Duration') {
                                const duration = parseInt(data.config.notificationStyles[prop]);
                                if (!isNaN(duration) && duration >= 1000 && duration <= 30000) {
                                    safeStyles[prop] = duration;
                                }
                            } else if (typeof data.config.notificationStyles[prop] === 'string') {
                                if (!data.config.notificationStyles[prop].includes('javascript:') && 
                                    !data.config.notificationStyles[prop].includes('expression')) {
                                    safeStyles[prop] = data.config.notificationStyles[prop];
                                }
                            }
                        }
                    }
                    
                    Object.assign(config.notificationStyles, safeStyles);
                }
                
                if (data.config.notificationTypes && typeof data.config.notificationTypes === 'object') {
                    const safeTypes = {};
                    const allowedTypes = ['success', 'error', 'info', 'warning'];
                    
                    for (const type of allowedTypes) {
                        if (data.config.notificationTypes[type] && 
                            typeof data.config.notificationTypes[type] === 'object') {
                            
                            safeTypes[type] = {};
                            const typeData = data.config.notificationTypes[type];
                            
                            if (typeData.icon && typeof typeData.icon === 'string') {
                                if (typeData.icon.match(/^<i class="fa[srlbd]? fa-[\w-]+"><\/i>$/)) {
                                    safeTypes[type].icon = typeData.icon;
                                }
                            }
                            
                            if (typeData.borderColor && typeof typeData.borderColor === 'string') {
                                safeTypes[type].borderColor = typeData.borderColor;
                            }
                            
                            if (typeData.backgroundColor && typeof typeData.backgroundColor === 'string') {
                                safeTypes[type].backgroundColor = typeData.backgroundColor;
                            }
                        }
                    }
                    
                    for (const type in safeTypes) {
                        if (config.notificationTypes[type]) {
                            Object.assign(config.notificationTypes[type], safeTypes[type]);
                        }
                    }
                }
            }
        } else if (data.action === 'initialize') {
            document.documentElement.style.backgroundColor = 'transparent';
            document.body.style.backgroundColor = 'transparent';
        } else if (data.action === 'playSound') {
        }
    } catch (error) {
        console.error('Error processing NUI message:', error);
    }
});

window.onload = function() {
    try {
        document.documentElement.style.backgroundColor = 'transparent';
        document.body.style.backgroundColor = 'transparent';
        
        let resourceName;
        try {
            resourceName = GetParentResourceName();
        } catch (e) {
            console.log('GetParentResourceName not available, using fallback');
            resourceName = 'dnd-notify';
        }
        
        fetch(`https://${resourceName}/nuiReady`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).catch(() => {
        });
    } catch (error) {
        console.error('Error in window.onload:', error);
    }
};
