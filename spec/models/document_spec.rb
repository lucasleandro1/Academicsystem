# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  describe "associations" do
    it { should belong_to(:school) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:document_type) }
  end

  describe "scopes" do
    let!(:municipal_doc) { create(:document, :municipal) }
    let!(:school_doc) { create(:document, :school_specific) }
    let!(:bulletin_doc) { create(:document, :bulletin) }
    let!(:certificate_doc) { create(:document, :certificate) }

    describe ".municipal" do
      it "returns only municipal documents" do
        expect(Document.municipal).to include(municipal_doc)
        expect(Document.municipal).not_to include(school_doc)
      end
    end

    describe ".school_specific" do
      it "returns only school-specific documents" do
        expect(Document.school_specific).to include(school_doc)
        expect(Document.school_specific).not_to include(municipal_doc)
      end
    end

    describe ".by_type" do
      it "filters documents by type" do
        expect(Document.by_type("boletim")).to include(bulletin_doc)
        expect(Document.by_type("boletim")).not_to include(certificate_doc)
      end
    end
  end

  describe "constants" do
    it "defines DOCUMENT_TYPES" do
      expected_types = [
        "boletim", "historico", "ocorrencia", "comunicado", "regulamento",
        "circular", "ata", "certificado", "declaracao", "outros"
      ]
      expect(Document::DOCUMENT_TYPES).to eq(expected_types)
    end
  end

  describe "methods" do
    describe "#municipal?" do
      it "returns true for municipal documents" do
        document = build(:document, is_municipal: true)
        expect(document.municipal?).to be true
      end

      it "returns false for non-municipal documents" do
        document = build(:document, is_municipal: false)
        expect(document.municipal?).to be false
      end
    end
  end
end
