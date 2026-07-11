# Simple main.py that demonstrates the AI agent
from ai_agent import IntegratedAIAgent

def main():
    print("Integrated AI Agent Demo")
    print("=" * 40)
    agent = IntegratedAIAgent()
    status = agent.get_system_status()
    print(f"LLM Resources: {"Available" if status["llm_resources"]["available"] else "Not Available"}")
    print(f"Ponytail Skills: {"Available" if status["ponytail_skills"]["available"] else "Not Available"}")
    print(f"FCC Proxy: {"Available" if status["free_claude_code_proxy"]["available"] else "Not Available"}")

    print("\nAvailable Providers:")
    providers = agent.llm_resources.list_available_providers()
    for provider in providers[:5]:
        print(f"  - {provider}")
    if len(providers) > 5:
        print(f"  ... and {len(providers) - 5} more")

    print("\nExample Task:")
    result = agent.execute_agent_task("Analyze customer feedback sentiment")
    print(f"Task: {result["task"]}")
    print(f"Safety: {result["safety_constraints"]}")

    print("\nAI Agent ready for use!")

if __name__ == "__main__":
    main()
