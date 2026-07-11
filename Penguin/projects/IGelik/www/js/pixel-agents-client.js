/**
 * Pixel Agents Client
 * Communicates with Pixel Agents Server from IGelik
 */

class PixelAgentsClient {
  constructor(baseUrl = 'http://127.0.0.1:46699') {
    this.baseUrl = baseUrl;
    this.connected = false;
    this.agents = [];
    this.messageHistory = [];
    this.currentAgent = null;
    this.initializeConnection();
  }

  /**
   * Initialize connection to pixel-agents server
   */
  async initializeConnection() {
    try {
      const response = await fetch(`${this.baseUrl}/health`);
      if (response.ok) {
        this.connected = true;
        console.log('✅ Connected to Pixel Agents Server');
        await this.loadAgents();
      }
    } catch (error) {
      console.warn('⚠️ Could not connect to Pixel Agents Server:', error.message);
      this.connected = false;
    }
  }

  /**
   * Load available agents from server
   */
  async loadAgents() {
    try {
      const response = await fetch(`${this.baseUrl}/api/agents`);
      if (response.ok) {
        const data = await response.json();
        this.agents = data.agents;
        if (this.agents.length > 0) {
          this.currentAgent = this.agents[0];
        }
        return this.agents;
      }
    } catch (error) {
      console.error('Error loading agents:', error);
      return [];
    }
  }

  /**
   * Send chat message to agent
   */
  async sendMessage(content, agentId = null) {
    if (!this.connected) {
      throw new Error('Pixel Agents Server is not connected');
    }

    const agent = agentId ? this.agents.find(a => a.id === agentId) : this.currentAgent;
    if (!agent) {
      throw new Error('Agent not found');
    }

    // Add user message to history
    this.messageHistory.push({
      role: 'user',
      content: content,
      timestamp: new Date()
    });

    try {
      const response = await fetch(`${this.baseUrl}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messages: this.messageHistory.map(msg => ({\n            role: msg.role,\n            content: msg.content\n          })),
          model: 'claude-3-5-sonnet-20241022',
          temperature: 0.7,
          max_tokens: 2048
        })
      });

      if (response.ok) {
        const data = await response.json();
        const assistantMessage = data.response;
        
        // Add assistant message to history
        this.messageHistory.push({
          role: assistantMessage.role,
          content: assistantMessage.content,
          timestamp: new Date()
        });

        return {
          agent: agent.name,
          message: assistantMessage.content,
          timestamp: new Date()
        };
      } else {
        throw new Error(`Server error: ${response.statusText}`);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

  /**
   * Execute a specific agent task
   */
  async executeTask(agentType, task, context = null) {
    if (!this.connected) {
      throw new Error('Pixel Agents Server is not connected');
    }

    try {
      const response = await fetch(`${this.baseUrl}/api/execute`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          agent_type: agentType,
          task: task,
          context: context
        })
      });

      if (response.ok) {
        return await response.json();
      } else {
        throw new Error(`Server error: ${response.statusText}`);
      }
    } catch (error) {
      console.error('Error executing task:', error);
      throw error;
    }
  }

  /**
   * Get agent status
   */
  async getStatus() {
    try {
      const response = await fetch(`${this.baseUrl}/api/status`);
      if (response.ok) {
        return await response.json();
      }
    } catch (error) {
      console.error('Error getting status:', error);
    }
    return null;
  }

  /**
   * Get current conversation history
   */
  getHistory() {
    return this.messageHistory;
  }

  /**
   * Clear conversation history
   */
  clearHistory() {
    this.messageHistory = [];
  }

  /**
   * Select agent by ID
   */
  selectAgent(agentId) {
    const agent = this.agents.find(a => a.id === agentId);
    if (agent) {
      this.currentAgent = agent;
      return agent;
    }
    throw new Error(`Agent ${agentId} not found`);
  }

  /**
   * Get current agent
   */
  getCurrentAgent() {
    return this.currentAgent;
  }

  /**
   * Check if connected
   */
  isConnected() {
    return this.connected;
  }
}

// Create global instance
const pixelAgentsClient = new PixelAgentsClient();
