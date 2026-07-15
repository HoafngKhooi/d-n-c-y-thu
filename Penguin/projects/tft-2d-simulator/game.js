// TFT 2D Simulator Game Logic

class TFTGame {
    constructor() {
        this.round = 1;
        this.zodiac = 0;
        this.gold = 10;
        this.health = 100;
        this.maxHealth = 100;
        
        // Game state
        this.bench = Array(7).fill(null); // 7 slots for bench
        this.shop = Array(5).fill(null); // 5 slots for shop
        this.grid = Array(6 * 4).fill(null); // 6x4 grid for arena
        
        // Unit data (simplified for demo)
        this.units = [
            { id: 1, name: "Garen", cost: 1, tier: 1, image: "⚔️" },
            { id: 2, name: "Teemo", cost: 1, tier: 1, image: "🍄" },
            { id: 3, name: "Annie", cost: 1, tier: 1, image: "🔥" },
            { id: 4, name: "Lux", cost: 2, tier: 2, image: "✨" },
            { id: 5, name: "Zed", cost: 2, tier: 2, image: "⚡" },
            { id: 6, name: "Katarina", cost: 2, tier: 2, image: "🗡️" },
            { id: 7, name: "Morgana", cost: 3, tier: 3, image: "👼" },
            { id: 8, name: "Yasuo", cost: 3, tier: 3, image: "🌪️" },
            { id: 9, name: "Jinx", cost: 3, tier: 3, image: "💣" },
            { id: 10, name: "Lux", cost: 4, tier: 4, image: "💎" },
            { id: 11, name: "Kayle", cost: 4, tier: 4, image: "👼" },
            { id: 12, name: "Kindred", cost: 5, tier: 5, image: "🦁" }
        ];
        
        // DOM elements
        this.elements = {
            round: document.getElementById('round'),
            zodiac: document.getElementById('zodiac'),
            gold: document.getElementById('gold'),
            health: document.getElementById('health'),
            benchSlots: document.getElementById('bench-slots'),
            gameGrid: document.getElementById('game-grid'),
            shopSlots: document.getElementById('shop-slots'),
            buyBtn: document.getElementById('buy-btn'),
            startRoundBtn: document.getElementById('start-round-btn'),
            resetBtn: document.getElementById('reset-btn')
        };
        
        this.init();
    }
    
    init() {
        this.render();
        this.bindEvents();
        this.refreshShop();
    }
    
    bindEvents() {
        this.elements.buyBtn.addEventListener('click', () => this.buyUnit());
        this.elements.startRoundBtn.addEventListener('click', () => this.startRound());
        this.elements.resetBtn.addEventListener('click', () => this.resetGame());
        
        // Make bench slots droppable
        this.elements.benchSlots.addEventListener('dragover', (e) => e.preventDefault());
        this.elements.benchSlots.addEventListener('drop', (e) => this.handleDrop(e, 'bench'));
        
        // Make grid cells droppable
        this.elements.gameGrid.addEventListener('dragover', (e) => e.preventDefault());
        this.elements.gameGrid.addEventListener('drop', (e) => this.handleDrop(e, 'grid'));
        
        // Make shop slots droppable (for selling)
        this.elements.shopSlots.addEventListener('dragover', (e) => e.preventDefault());
        this.elements.shopSlots.addEventListener('drop', (e) => this.handleDrop(e, 'shop'));
    }
    
    render() {
        // Update info display
        this.elements.round.textContent = this.round;
        this.elements.zodiac.textContent = this.zodiac;
        this.elements.gold.textContent = this.gold;
        this.elements.health.textContent = `${this.health}/${this.maxHealth}`;
        
        // Render bench
        this.renderBench();
        
        // Render grid
        this.renderGrid();
        
        // Render shop
        this.renderShop();
        
        // Update button states
        this.elements.buyBtn.disabled = this.gold < 2;
        this.elements.startRoundBtn.disabled = this.bench.some(unit => unit === null);
    }
    
    renderBench() {
        this.elements.benchSlots.innerHTML = '';
        this.bench.forEach((unit, index) => {
            const slot = document.createElement('div');
            slot.className = `slot ${unit ? 'occupied' : 'empty'}`;
            slot.draggable = !!unit;
            slot.dataset.index = index;
            slot.dataset.type = 'bench';
            
            if (unit) {
                slot.innerHTML = `
                    <div class="unit-img">${unit.image}</div>
                    <div class="unit-level">${unit.tier}</div>
                    <div class="unit-stars">
                        ${'★'.repeat(unit.tier < 3 ? unit.tier : 3)}
                    </div>
                `;
                
                slot.addEventListener('dragstart', (e) => this.handleDragStart(e, slot));
                slot.addEventListener('dragend', (e) => this.handleDragEnd(e));
            } else {
                slot.textContent = '+';
            }
            
            this.elements.benchSlots.appendChild(slot);
        });
    }
    
    renderGrid() {
        this.elements.gameGrid.innerHTML = '';
        this.grid.forEach((unit, index) => {
            const cell = document.createElement('div');
            cell.className = `cell ${unit ? 'occupied' : 'empty'}`;
            cell.dataset.index = index;
            cell.dataset.type = 'grid';
            
            if (unit) {
                cell.innerHTML = `
                    <div class="unit-img">${unit.image}</div>
                    <div class="unit-level">${unit.tier}</div>
                    <div class="unit-stars">
                        ${'★'.repeat(unit.tier < 3 ? unit.tier : 3)}
                    </div>
                `;
                
                cell.addEventListener('dragstart', (e) => this.handleDragStart(e, cell));
                cell.addEventListener('dragend', (e) => this.handleDragEnd(e));
            } else {
                cell.textContent = '+';
            }
            
            this.elements.gameGrid.appendChild(cell);
        });
    }
    
    renderShop() {
        this.elements.shopSlots.innerHTML = '';
        this.shop.forEach((unit, index) => {
            const slot = document.createElement('div');
            slot.className = `slot ${unit ? 'occupied' : 'empty'}`;
            slot.draggable = !!unit;
            slot.dataset.index = index;
            slot.dataset.type = 'shop';
            
            if (unit) {
                slot.innerHTML = `
                    <div class="unit-img">${unit.image}</div>
                    <div class="unit-level">${unit.tier}</div>
                    <div class="unit-stars">
                        ${'★'.repeat(unit.tier < 3 ? unit.tier : 3)}
                    </div>
                `;
                
                slot.addEventListener('dragstart', (e) => this.handleDragStart(e, slot));
                slot.addEventListener('dragend', (e) => this.handleDragEnd(e));
            } else {
                slot.textContent = '+';
            }
            
            this.elements.shopSlots.appendChild(slot);
        });
    }
    
    handleDragStart(e, element) {
        e.dataTransfer.setData('text/plain', JSON.stringify({
            type: element.dataset.type,
            index: parseInt(element.dataset.index)
        }));
        element.classList.add('dragging');
    }
    
    handleDragEnd(e) {
        document.querySelectorAll('.slot, .cell').forEach(el => {
            el.classList.remove('dragging');
        });
    }
    
    handleDrop(e, targetType) {
        e.preventDefault();
        const data = JSON.parse(e.dataTransfer.getData('text/plain'));
        
        const sourceType = data.type;
        const sourceIndex = data.index;
        
        let sourceUnit = null;
        if (sourceType === 'bench') {
            sourceUnit = this.bench[sourceIndex];
        } else if (sourceType === 'grid') {
            sourceUnit = this.grid[sourceIndex];
        } else if (sourceType === 'shop') {
            sourceUnit = this.shop[sourceIndex];
        }
        
        if (!sourceUnit) return;
        
        // Handle dropping to different areas
        if (targetType === 'bench') {
            // Find empty slot in bench
            const emptyIndex = this.bench.findIndex(unit => unit === null);
            if (emptyIndex !== -1) {
                // Move unit
                if (sourceType === 'shop' && this.gold >= sourceUnit.cost) {
                    // Buying from shop
                    this.gold -= sourceUnit.cost;
                    this.bench[emptyIndex] = { ...sourceUnit };
                    this.shop[sourceIndex] = null;
                } else if (sourceType === 'bench' || sourceType === 'grid') {
                    // Moving between bench/grid
                    if (sourceType === 'bench') {
                        this.bench[sourceIndex] = null;
                    } else {
                        this.grid[sourceIndex] = null;
                    }
                    this.bench[emptyIndex] = { ...sourceUnit };
                }
            }
        } else if (targetType === 'grid') {
            // Find empty slot in grid
            const emptyIndex = this.grid.findIndex(unit => unit === null);
            if (emptyIndex !== -1) {
                // Move unit
                if (sourceType === 'bench') {
                    this.bench[sourceIndex] = null;
                    this.grid[emptyIndex] = { ...sourceUnit };
                } else if (sourceType === 'grid') {
                    // Swap positions in grid
                    const temp = this.grid[sourceIndex];
                    this.grid[sourceIndex] = this.grid[emptyIndex];
                    this.grid[emptyIndex] = temp;
                }
            }
        } else if (targetType === 'shop') {
            // Selling unit to shop (for half price)
            if (sourceType === 'bench' || sourceType === 'grid') {
                const sellPrice = Math.max(1, Math.floor(sourceUnit.cost / 2));
                this.gold += sellPrice;
                
                if (sourceType === 'bench') {
                    this.bench[sourceIndex] = null;
                } else {
                    this.grid[sourceIndex] = null;
                }
            }
        }
        
        this.render();
    }
    
    refreshShop() {
        // Generate random units for shop based on round
        const availableUnits = this.units.filter(unit => unit.cost <= Math.min(5, Math.floor(this.round / 2) + 1));
        this.shop = Array(5).fill(null).map(() => {
            if (Math.random() > 0.3) { // 70% chance to show a unit
                const randomUnit = availableUnits[Math.floor(Math.random() * availableUnits.length)];
                return { ...randomUnit };
            }
            return null;
        });
    }
    
    buyUnit() {
        if (this.gold < 2) return;
        
        // Find empty bench slot
        const emptyIndex = this.bench.findIndex(unit => unit === null);
        if (emptyIndex === -1) {
            alert("Đội hình dự bị đã đầy!");
            return;
        }
        
        // Buy cheapest available unit (2 gold)
        const affordableUnits = this.shop.filter(unit => unit && unit.cost <= 2);
        if (affordableUnits.length === 0) {
            alert("Không có tướng nào giá 2 vàng trong cửa hàng!");
            return;
        }
        
        const unitToBuy = affordableUnits[Math.floor(Math.random() * affordableUnits.length)];
        const shopIndex = this.shop.findIndex(u => u && u.name === unitToBuy.name && u.cost === unitToBuy.cost);
        
        if (shopIndex !== -1) {
            this.gold -= 2;
            this.bench[emptyIndex] = { ...unitToBuy };
            this.shop[shopIndex] = null;
            this.render();
        }
    }
    
    startRound() {
        // Check if bench is full
        if (this.bench.some(unit => unit === null)) {
            alert("Vui lòng điền đầy đội hình dự bị trước khi bắt đầu vòng!");
            return;
        }
        
        // Simulate round
        this.round++;
        this.zodiac = Math.min(10, this.zodiac + 2);
        this.gold += Math.floor(this.round / 2) + 1; // Gold income
        
        // Random health loss/gain
        const healthChange = Math.floor(Math.random() * 10) - 5;
        this.health = Math.max(0, Math.min(this.maxHealth, this.health + healthChange));
        
        // Refresh shop for next round
        this.refreshShop();
        
        this.render();
        
        // Show round result
        setTimeout(() => {
            if (this.health <= 0) {
                alert("Game Over! Bạn đã thua.");
                this.resetGame();
            } else if (this.round > 10) {
                alert("Chúc mừng! Bạn đã vượt qua 10 vòng.");
            } else {
                alert(`Vòng ${this.round - 1} kết thúc! Zodiac: ${this.zodiac}/10, Số dư: ${this.gold} Vàng`);
            }
        }, 500);
    }
    
    resetGame() {
        this.round = 1;
        this.zodiac = 0;
        this.gold = 10;
        this.health = 100;
        
        this.bench = Array(7).fill(null);
        this.shop = Array(5).fill(null);
        this.grid = Array(6 * 4).fill(null);
        
        this.refreshShop();
        this.render();
    }
}

// Initialize game when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.tftGame = new TFTGame();
});