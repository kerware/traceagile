import { describe, expect, it, vi } from 'vitest';
import { handleStaleChunk, RELOAD_KEY } from './staleBuild';

function fakeStorage() {
  const data = new Map<string, string>();
  return { getItem: (k: string) => data.get(k) ?? null, setItem: (k: string, v: string) => void data.set(k, v) };
}

describe('NF-14 page ouverte avant un redéploiement : un morceau chargé à la demande a disparu', () => {
  it('recharge la page une fois pour obtenir la nouvelle version', () => {
    const reload = vi.fn();
    const event = { preventDefault: vi.fn() };
    const storage = fakeStorage();
    expect(handleStaleChunk(event, { reload, storage, now: () => 1_000 })).toBe(true);
    expect(event.preventDefault).toHaveBeenCalled();
    expect(reload).toHaveBeenCalledOnce();
    expect(storage.getItem(RELOAD_KEY)).toBe('1000');
  });

  it('ne recharge pas en boucle : un second échec dans la minute laisse l’erreur s’afficher', () => {
    const reload = vi.fn();
    const event = { preventDefault: vi.fn() };
    const storage = fakeStorage();
    storage.setItem(RELOAD_KEY, '1000');
    expect(handleStaleChunk(event, { reload, storage, now: () => 30_000 })).toBe(false);
    expect(reload).not.toHaveBeenCalled();
    expect(event.preventDefault).not.toHaveBeenCalled();
    expect(handleStaleChunk(event, { reload, storage, now: () => 70_000 })).toBe(true);
  });

  it('recharge quand même si le stockage de session est indisponible', () => {
    const reload = vi.fn();
    const storage = { getItem: () => { throw new Error('bloqué'); }, setItem: () => { throw new Error('bloqué'); } };
    expect(handleStaleChunk({ preventDefault: vi.fn() }, { reload, storage, now: () => 1 })).toBe(true);
    expect(reload).toHaveBeenCalledOnce();
  });
});
