# An iChatBio expert agent for one small resource: a checklist of names.
# It looks a name up in the file and never generates one.
import csv

from pydantic import BaseModel
from ichatbio.agent import IChatBioAgent
from ichatbio.server import run_agent_server
from ichatbio.types import AgentCard, AgentEntrypoint


class Lookup(BaseModel):
    name: str  # the scientific name to look up


CARD = AgentCard(
    name="Checklist agent",
    description="Says whether a scientific name is on our checklist.",
    url="http://localhost:9999",
    entrypoints=[AgentEntrypoint(
        id="lookup",
        description="Looks one scientific name up in the checklist.",
        parameters=Lookup)])


class ChecklistAgent(IChatBioAgent):
    def get_agent_card(self):
        return CARD

    async def run(self, context, request, entrypoint, params,
                  metadata=None):
        with open("data/raw/checklist.csv") as f:
            names = {row["scientific_name"] for row in csv.DictReader(f)}
        async with context.begin_process("Reading the checklist") as p:
            found = params.name.strip() in names
            await p.log(f"{len(names)} names read; match: {found}")
        await context.reply(
            f"'{params.name}' is on the checklist." if found else
            f"'{params.name}' is not on the checklist. I correct nothing.")


if __name__ == "__main__":
    run_agent_server(ChecklistAgent(), host="127.0.0.1", port=9999)
