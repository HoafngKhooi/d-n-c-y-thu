/**
 * Pixel Agents UI Integration for IGelik
 * Handles the "Văn phòng AI" (AI Office) tab integration
 */

// Office UI Module
const officeUI = {
  container: null,
  
  init() {
    console.log('Initializing Office UI...');
    
    if (!pixelAgentsClient) {
      console.error('Pixel Agents Client not loaded');
      return;
    }
    
    // Wait for agents to load
    setTimeout(() => this.render(), 500);
  },

  render() {
    const container = document.querySelector('[data-page="office"]');
    
    if (!container) {
      console.warn('Office container not found');
      return;
    }

    let html = `
      <div class="office-container">
        <div class="office-header">
          <h2>🏢 Văn phòng AI</h2>
          <p>Quản lý và tương tác với các Agent</p>
        </div>

        <div class="office-status">
          <div class="status-indicator ${pixelAgentsClient.isConnected() ? 'connected' : 'disconnected'}"></div>
          <span>${pixelAgentsClient.isConnected() ? '✅ Kết nối' : '❌ Không kết nối'}</span>
        </div>

        ${pixelAgentsClient.isConnected() ? this.renderAgents() : this.renderConnectionError()}
      </div>
    `;

    container.innerHTML = html;
    this.attachEventListeners();
  },

  renderAgents() {
    const agents = pixelAgentsClient.agents;
    
    if (agents.length === 0) {
      return '<div class="office-message">Không có agent nào</div>';
    }

    let html = `
      <div class="agents-section">
        <h3>Các Agent Có Sẵn</h3>
        <div class="agents-grid">
    `;

    agents.forEach(agent => {
      html += `
        <div class="agent-card" data-agent-id="${agent.id}">
          <div class="agent-header">
            <h4>${agent.name}</h4>
            <span class="agent-status ${agent.status}">${agent.status}</span>
          </div>
          <p class="agent-description">${agent.description}</p>
          <div class="agent-capabilities">
            <small>Khả năng:</small>
            <div class="capabilities-list">
              ${agent.capabilities.map(cap => `<span class="capability-tag">${cap}</span>`).join('')}
            </div>
          </div>
          <button class="btn btn-primary" onclick="officeUI.selectAgent('${agent.id}')">
            Chọn Agent
          </button>
        </div>
      `;
    });

    html += `
        </div>
      </div>
      
      <div class="chat-section">
        <h3>Trò Chuyện với Agent</h3>
        <div class="agent-chat-box">
          <div id="office-chat-messages" class="chat-messages"></div>
          <div class="chat-input-area">
            <input type="text" id="office-chat-input" placeholder="Nhập tin nhắn...">
            <button onclick="officeUI.sendMessage()" class="btn btn-primary">Gửi</button>
          </div>
        </div>
      </div>
    `;

    return html;
  },

  renderConnectionError() {
    return `
      <div class="office-error">
        <p>⚠️ Không thể kết nối đến Pixel Agents Server</p>
        <p>Đảm bảo rằng server đang chạy tại: http://127.0.0.1:8001</p>
        <button class="btn btn-primary" onclick="location.reload()">Thử lại</button>
      </div>
    `;
  },

  attachEventListeners() {
    const input = document.getElementById('office-chat-input');
    if (input) {
      input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          this.sendMessage();
        }
      });
    }
  },

  selectAgent(agentId) {
    try {
      pixelAgentsClient.selectAgent(agentId);
      console.log('Agent selected:', agentId);
      this.render();
    } catch (error) {
      console.error('Error selecting agent:', error);
      alert('Lỗi chọn agent: ' + error.message);
    }
  },

  async sendMessage() {
    const input = document.getElementById('office-chat-input');
    const messagesContainer = document.getElementById('office-chat-messages');
    
    if (!input || !input.value.trim()) {
      return;
    }

    const message = input.value.trim();
    input.value = '';

    try {
      // Display user message
      this.addMessageToChat('user', message, messagesContainer);

      // Send to agent
      const response = await pixelAgentsClient.sendMessage(message);
      
      // Display agent response
      this.addMessageToChat('assistant', response.message, messagesContainer);

    } catch (error) {
      console.error('Error sending message:', error);
      this.addMessageToChat('error', 'Lỗi: ' + error.message, messagesContainer);
    }
  },

  addMessageToChat(role, content, container) {
    if (!container) return;

    const messageEl = document.createElement('div');
    messageEl.className = `message message-${role}`;
    messageEl.innerHTML = `
      <div class="message-content">${this.escapeHtml(content)}</div>
      <span class="message-time">${new Date().toLocaleTimeString('vi-VN')}</span>
    `;

    container.appendChild(messageEl);
    container.scrollTop = container.scrollHeight;
  },

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
};

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
  officeUI.init();
});
