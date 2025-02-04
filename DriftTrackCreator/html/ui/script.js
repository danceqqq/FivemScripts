document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('modal');
    const raceInfo = document.getElementById('raceInfo');
    const raceForm = document.getElementById('raceForm');
    const timeDisplay = document.getElementById('time');
    const pointsDisplay = document.getElementById('points');

    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'open') {
            if (data.type === 'create_race') {
                modal.classList.remove('hidden');
                document.title = 'Создание трассы';
            } else if (data.type === 'race_info') {
                raceInfo.classList.remove('hidden');
                timeDisplay.textContent = data.timeLimit;
                pointsDisplay.textContent = 0;
            }
        } else if (data.action === 'close') {
            modal.classList.add('hidden');
            raceInfo.classList.add('hidden');
        }
    });

    raceForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const name = document.getElementById('name').value;
        const type = document.getElementById('type').value;
        fetch(`https://your-resource-name/submit`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: 'create_race', name, type })
        });
    });
});
